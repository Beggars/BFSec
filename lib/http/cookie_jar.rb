module BFSec
    module HTTP
        class CookieJar
            def load(cookie_jar_file, url='')
                if File.exists?(cookie_jar_file)
                    puts "cookie_jar #{cookie_jar_file} doesn't exists"
                end
            end

            def update(cookies)
                [cookies].flatten.compact.each do |c|
                    self << case c
                        when String
                            begin
                                Cookie.from_string
                            rescue Exception => e

                            end
                        end

                end
            end

        end
    end
end
