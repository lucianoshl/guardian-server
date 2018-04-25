# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['ENV'] || 'development')

require_rel '../lib/requirer.rb'
require_rel '../lib/sinatra'

run GuardianSinatraApp
