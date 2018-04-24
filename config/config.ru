require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['ENV'] || 'development')
require 'rack/contrib'
require 'rack/mount'
require 'require_all'

require_rel '../lib/requirer.rb'
require_rel '../lib/sinatra'

run GuardianSinatraApp
