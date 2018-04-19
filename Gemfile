# frozen_string_literal: true

ruby '2.5.1'

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# app
gem "sinatra", require: false
gem "mongoid"

# jobs
gem 'delayed_job'
gem 'delayed_job_mongoid'
gem 'daemons'

# general
gem 'require_all'
gem 'logger'
gem 'rake'

gem "rack-graphiql"

group :test, :development do
  gem "pry"
  gem "pry-nav"
  gem "sinatra-reloader"
end

group :production do
  gem 'foreman'
end