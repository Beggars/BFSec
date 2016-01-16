class App < Sinatra::Base
    namespace '/baidu' do
      get '/user/:username' do
        @username = params['username']
        @bd_users = BdUser.take(100)
        erb :"/baidu/user"
      end
    end
end
