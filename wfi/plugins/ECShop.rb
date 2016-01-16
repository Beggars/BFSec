Plugin.define 'ECShop' do
  author 'Brendan Coles <bcoles@gmail.com>' # 2011-03-18
  version '0.1'
  description 'Ecshop is an Open Source Ecommerce Platform - Homepage: http://www.ecshop.org/'

  matches [
    {:certainty => 25, :regexp => /<title>[^<]+ - Powered by ECShop<\/title>/},
    {:version => /<meta name="Generator" content="ECSHOP v([\d\.]+)" \/>/},
  ]

end