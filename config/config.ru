# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['ENV'] || 'development')

require_rel '../lib/requirer.rb'
Requirer.with_sub_folder_as_namespace('sinatra')
require_rel '../lib/sinatra/web_app.rb'

run WebApp
