# frozen_string_literal: true

ruby '2.5.1'

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# app
gem 'mongoid'
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

group :test, :development do
  gem 'pry'
  gem 'pry-nav'
  gem 'rspec'
  gem 'rubocop', require: false
  gem 'sinatra-reloader'
end

group :production do
  gem 'foreman'
end