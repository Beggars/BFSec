require "uri"

uri = URI.parse("http://www.baidu.com/a/b/c/d/b.php")
path_segment = uri.path.split('/')

if path_segment.size > 0
  path_segment.each_index do |index|
    if index != 0
      t = ''
      (index).times do |i|
        t += path_segment[i] + '/'
      end
      puts "http://www.baidu.com" + t
    end
  end
end


