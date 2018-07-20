# frozen_string_literal: true

require 'sinatra'
# require 'sinatra/base'
# require 'sinatra/json'

class GuardianSinatraApp < Sinatra::Base

  register Sinatra::Reloader

  get '/reset' do
    Mongoid.purge!
    return redirect '/'
  end

  get '/' do
    @main_account = Account.main
    return erb :login, layout: :base if @main_account.nil?
    return erb :worlds, layout: :base if @main_account.world.nil?
    return erb :home, layout: :base
  end

  post '/' do
    @main_account = Account.main
    if @main_account.nil?
      account = Account.new params['account']
      account.login
      account.main = true
      account.save
      return redirect '/'
    end

    if @main_account.world.nil?
      @main_account.world = params['world']
      @main_account.save
      return redirect '/'
    end
  end

  post '/graphql' do
    params = JSON.parse request.body.read
    result = GuardianSchema.execute(
      params['query'],
      variables: params['variables'],
      context: { current_user: nil }
    )
    json result
  end

  get '/graphiql' do
    Rack::GraphiQL.new(endpoint: '/graphql').call(request.env)
  end

  get '/healthcheck' do
  end
end
