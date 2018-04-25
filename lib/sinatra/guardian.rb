# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'

class GuardianSinatraApp < Sinatra::Base
  get '/' do
    erb :index
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
