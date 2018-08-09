# frozen_string_literal: true

module Routes::Login
  def self.registered(app)
    app.get '/' do
      @main_account = Account.main
      return proxy_request('https://www.tribalwars.com.br/') if @main_account.nil?
      return proxy_request('https://www.tribalwars.com.br/') if @main_account.world.nil?
      return 'nothins'
    end

    app.post '/page/auth' do
      result = proxy_request('https://www.tribalwars.com.br/')
      parsed_result = JSON.parse(result)
      if parsed_result['status'] == 'success'
        account = Account.main || Account.new(
          username: params['username'],
          password: params['password'],
          main: true
        )
        account.save
      end
      return result
    end

    app.get '/page/play/:world' do
      account = Account.main
      account.world = params[:world]
      account.save
      result = proxy_request('https://www.tribalwars.com.br/')
      redirect '/'
    end

    app.post '/page/join/:world/confirm' do
      account = Account.main
      account.world = params[:world]
      account.save
      return proxy_request('https://www.tribalwars.com.br/')
    end
  end
end
