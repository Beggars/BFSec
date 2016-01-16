require 'eventmachine'
require 'resolv'

module EventMachine
  module DnsResolver
    ##
    # Global interface
    ##

    Port = 53

    def self.resolve(hostname)
      type = Resolv::DNS::Resource::IN::A
      if ::Resolv::AddressRegex =~ hostname
        # hostname contains an IP address, nothing to resolve
        Request.new(nil, hostname, type)
      else
        Request.new(socket, hostname, type)
      end
    end

    def self.reverse(address)
      case address
      when Resolv::IPv4::Regex
        ptr = Resolv::IPv4.create(address).to_name
      when Resolv::IPv6::Regex
        ptr = Resolv::IPv6.create(address).to_name
      else
        raise ArgumentError, "invalid address: #{address}"
      end
      Request.new(socket, ptr, Resolv::DNS::Resource::IN::PTR)
    end

    def self.socket
      if defined?(@socket) && @socket.connected?
        @socket
      else
        @socket = DnsSocket.open
      end
    end

    def self.nameserver_port= (ns_p)
      @nameserver_port = ns_p
    end
    def self.nameserver_port
      return @nameserver_port if defined? @nameserver_port
      config_hash = ::Resolv::DNS::Config.default_config_hash
      @nameserver_port = if config_hash.include? :nameserver
        [ config_hash[:nameserver].first, Port ]
      elsif config_hash.include? :nameserver_port
        config_hash[:nameserver_port].first
      else
        [ '0.0.0.0', Port ]
      end
    end

    ##
    # Socket stuff
    ##

    class RequestIdAlreadyUsed < RuntimeError
    end

    class DnsSocket < EM::Connection
      def self.open
        EM::open_datagram_socket('0.0.0.0', 0, self)
      end
      def post_init
        @requests = {}
        @connected = true
        EM.add_periodic_timer(0.1, &method(:tick))
      end
      # Periodically called each second to fire request retries
      def tick
        @requests.each do |id,req|
          req.tick
        end
      end
      def register_request(id, req)
        if @requests.has_key?(id)
          raise RequestIdAlreadyUsed
        else
          @requests[id] = req
        end
      end
      def send_packet(pkt)
        send_datagram pkt, *nameserver_port
      end
      def nameserver_port= (ns_p)
        @nameserver_port = ns_p
      end
      def nameserver_port
        @nameserver_port ||= DnsResolver.nameserver_port
      end
      # Decodes the packet, looks for the request and passes the
      # response over to the requester
      def receive_data(data)
        msg = nil
        begin
          msg = Resolv::DNS::Message.decode data
        rescue
        else
          req = @requests[msg.id]
          if req
            @requests.delete(msg.id)
            req.receive_answer(msg)
          end
        end
      end
      def connected?; @connected; end
      def unbind
        @connected = false
      end
    end

    ##
    # Request
    ##

    class Request
      include Deferrable
      attr_accessor :retry_interval
      attr_accessor :max_tries
      def initialize(socket, value, type)
        @socket = socket
        @value = value
        @type = type
        @tries = 0
        @last_send = Time.at(0)
        @retry_interval = 3
        @max_tries = 5
        EM.next_tick { tick }
      end
      def tick
        # @value already contains the response
        if @socket.nil?
          succeed [ @value ]
          return
        end

        # Break early if nothing to do
        return if @last_send + @retry_interval > Time.now

        if @tries < @max_tries
          send
        else
          fail 'retries exceeded'
        end
      end
      # Called by DnsSocket#receive_data
      def receive_answer(msg)
        result = []
        msg.each_answer do |name,ttl,data|
          case data
          when Resolv::DNS::Resource::IN::A, Resolv::DNS::Resource::IN::AAAA
            result << data.address.to_s
          when Resolv::DNS::Resource::IN::PTR
            result << data.name.to_s
          end
        end
        if result.empty?
          fail "rcode=#{msg.rcode}"
        else
          succeed result
        end
      end
      private
      def send
        @socket.send_packet(packet.encode)
        @tries += 1
        @last_send = Time.now
      end
      def id
        begin
          @id = rand(65535)
          @socket.register_request(@id, self)
        rescue RequestIdAlreadyUsed
          retry
        end unless defined?(@id)

        @id
      end
      def packet
        msg = Resolv::DNS::Message.new
        msg.id = id
        msg.rd = 1
        msg.add_question @value, @type
        msg
      end
    end
  end
end

# Pure Ruby DNS resolution
require 'resolv'
# Override sockets to use Ruby DNS resolution
require 'resolv-replace'

# require 'em-dns-resolver'
require 'fiber'

# Now override the override with EM-aware functions
class Resolv
  alias :orig_getaddress :getaddress

  def getaddress(host)
    event_machine? ? em_getaddresses(host)[0] : orig_getaddress(host)
  end

  alias :orig_getaddresses :getaddresses

  def getaddresses(host)
    event_machine? ? em_getaddresses(host) : orig_getaddresses(host)
  end

  alias :orig_getname :getname

  def getname(address)
    event_machine? ? em_getnames(address)[0] : orig_getname(address)
  end

  alias :orig_getnames :getnames

  def getnames(address)
    event_machine? ? em_getnames(address) : orig_getnames(address)
  end

  private

  def event_machine?
    EM.reactor_running? && EM.reactor_thread?
  end

  def em_getaddresses(host)
    em_request(host, :each_address, :resolve)
  end

  def em_getnames(address)
    em_request(address, :each_name, :reverse)
  end

  def em_request(value, hosts_method, resolv_method)
    # Lookup in /etc/hosts
    result = []
    @hosts ||= Resolv::Hosts.new
    @hosts.send(hosts_method, value) { |x| result << x.to_s }
    return result unless result.empty?

    # Nothing, hit DNS
    fiber = Fiber.current
    df = EM::DnsResolver.send(resolv_method, value)
    df.callback do |a|
      fiber.resume(a)
    end
    df.errback do |*a|
      fiber.resume(ResolvError.new(a.inspect))
    end
    result = Fiber.yield
    if result.is_a?(StandardError)
      raise result
    end
    result
  end
end

r = Resolv.new

$basedir = "/Users/ruby/Desktop/BFSec"

subdomain_list = Queue.new

File.open("#{$basedir}/wordlist/domain.lst", "r") do |f|
  f.readlines.each do |line|
    subdomain_list << line.chomp
  end
end

require "time"
#程序开始的时间
$total_time_begin = Time.now.to_i

threads = []
# threadNums
threadNums = 10
threadNums.times do
  threads << Thread.new do
    until subdomain_list.empty?
      subdomain = subdomain_list.pop(true)
      begin
        resolved_address = r.getaddress("#{subdomain}.xilu.com")
        if resolved_address
          puts "#{subdomain}.xilu.com\t#{resolved_address}"
        end
      rescue Exception => e
        # puts e.to_s
      end
    end
  end
end

threads.each{|t| t.join}

$total_time_end = Time.now.to_i
puts "线程数：" + threadNums.to_s
puts "执行时间：" + ($total_time_end - $total_time_begin).to_s + "秒"












