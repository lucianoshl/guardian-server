require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default, ENV['ENV'] || 'development')

require_rel '../lib/requirer.rb'
require_rel '../lib/sinatra'

run GuardianSinatraApp
