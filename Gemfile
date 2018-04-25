# frozen_string_literal: true

ruby '2.5.1'

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# app
gem 'graphql'
gem 'mongoid'
gem 'rack'
gem 'rack-contrib'
gem 'rack-mount'
gem 'sinatra', require: false

# jobs
gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_mongoid'

# general
gem 'logger'
gem 'rake'
gem 'require_all'

gem 'rack-graphiql'

group :test do 
  gem 'coveralls', require: false
  gem 'rspec'
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end

group :development do 
  gem 'rubocop', require: false
  gem 'sinatra-reloader'
end

group :test, :development do
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-stack_explorer'
end

group :production do
  gem 'foreman'
end
