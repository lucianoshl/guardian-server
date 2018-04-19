require 'rubygems'
require 'bundler'
Bundler.require(:default)
require 'sinatra'

require_rel '../lib/requirer.rb'

get '/' do
  'Put this in your pipe & smoke it!'
end

get '/healthcheck' do
  
end