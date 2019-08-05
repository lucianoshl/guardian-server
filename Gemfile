# frozen_string_literal: true

ruby '2.5.5'

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# app
gem 'graphql'
gem 'mongo', '2.8.0'
gem 'mongoid', '6.4.1'
gem 'rack'
gem 'rack-contrib'
gem 'rack-mount'
gem 'sinatra', require: false

# jobs
gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_mongoid'

# general
gem 'cachy'
gem 'colorize'
gem 'filewatcher'
gem 'json'
gem 'logger'
gem 'mechanize'
gem 'moneta'
gem 'parallel'
gem 'rake'
gem 'require_all'
gem 'ruby-progressbar'
gem 'washbullet'
gem 'wisper'

gem 'r18n-core'
gem 'rack-graphiql'
gem 'ruby-prof'

group :test do
  gem 'coveralls', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end

# group :development do
#   gem 'rubocop', require: false
# end

group :test, :development do
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'rspec'
  gem 'webmock'
end

group :production do
  gem 'foreman'
end
