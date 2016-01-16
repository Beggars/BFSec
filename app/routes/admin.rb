class App < Sinatra::Base
    namespace '/admin' do
      get '/' do
        @bd_users = BdUser.all
        erb :"/admin/index"
      end
    end
end
