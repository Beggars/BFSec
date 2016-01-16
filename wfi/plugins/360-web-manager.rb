Plugin.define '360-Web-Manager' do
  author 'Brendan Coles <bcoles@gmail.com>'
  version '0.2'
  description '360-Web-Manager - homepage: http://www.360webmanager.com'
  matches [
    { :regexp=>/360WebManager Software :: administrador contenidos web/, :certainty=>75 },
    { :version=>/<div align="center"><span class="copyr">Powered by <a href="http:\/\/www.360webmanager.com" target="_blank" class="copyrlink">360 Web Manager<\/a> ([\d\.]+)/ },
  ]
end

