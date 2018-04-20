# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['ENV'])
require 'sinatra'
require 'sinatra/json'
require 'rack/contrib'

require_rel '../lib/requirer.rb'

get '/' do
  'Put this in your pipe & smoke it!'
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
