require 'rubygems'
require 'bundler'
Bundler.require(:default,ENV['ENV'])
require 'sinatra'

require_rel '../lib/requirer.rb'

get '/' do
  'Put this in your pipe & smoke it!'
end

get '/graphiql' do
  Rack::GraphiQL.new(endpoint: '/graphql').call(request.env)
end

get '/healthcheck' do

end