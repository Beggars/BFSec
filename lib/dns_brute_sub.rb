require 'resolv'

$basedir = "/Users/ruby/Desktop/BFSec"

subdomain_list = []
File.open("#{$basedir}/wordlist/domain.lst", "r") do |f|
  subdomain_list = f.readlines
end

subdomain_list.each do |subdomain|
  subdomain = subdomain.chomp
  begin
    brute_domain ="#{subdomain}.xilu.com"
    resolved_address = Resolv.getaddress(brute_domain)
    if resolved_address
      puts "#{brute_domain}\t#{resolved_address}"
    end
  rescue Exception => e
    puts e.to_s
  end
end
