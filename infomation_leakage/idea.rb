require 'net/http'
require 'thread'
require 'uri'

queue = Queue.new
threads = []

File.open('./path_urls.lst', 'r') do |fh|
  fh.each_line do |line|
    queue << line.chomp
  end
end

# http://example.com
# http://example.com/
# http://example.com/foo
# http://example.com/foo/bar
def run(url)
  payload='.idea/workspace.xml'
  begin
    uri = URI.parse(url)
    path_segment = uri.path.split('/')
    if path_segment.size > 0
      path_segment.each_index do |index|
        if index != 0
          check_path = ''
          (index).times do |i|
            check_path += path_segment[i] + '/'
          end
          payload_url = "#{uri.scheme}://#{uri.host}:#{uri.port}#{check_path}#{payload}"
          check(payload_url)
        end
      end
    end
  rescue Exception => e
    # puts e.to_s
  end
end

def check(url)
  begin
    user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36'
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Get.new(uri.request_uri)
    request["User-Agent"] = "#{user_agent} BFSEC"

    response = http.request(request)

    if response.code == '200'
      search_content = response.body
      if search_content.include?('<?xml version="1.0" encoding="UTF-8"?>') and search_content.include?('</project>')
        puts url
      end
    end

  rescue Exception => e
    # puts e.to_s
  end
end


16.times do
  threads << Thread.new do
    until queue.empty?
      url = queue.pop(true)
      run(url)
    end
  end
end

threads.each { |t| t.join }

