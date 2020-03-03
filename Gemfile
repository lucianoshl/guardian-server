# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.7'

# possible remove
gem 'activesupport'
gem 'wisper', '2.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
# Use Puma as the app server
gem 'puma', '~> 4.3.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'rspec-rails'
  gem 'webdrivers', '~> 4.0'
  gem 'webmock'
end

group :test do
  gem 'coveralls', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'colorize'
gem 'figaro'
gem 'graphiql-rails'
gem 'graphql'
gem 'mechanize'
gem 'mongo', '2.8.0'
gem 'mongoid', '6.4.1'
gem 'parallel'

gem 'watir'

gem 'kaminari-mongoid'
gem 'rails_admin', '~> 2.0.0.rc'

# jobs
gem 'daemons'
gem 'delayed_job'
gem 'delayed_job_mongoid'

# to remove
gem 'r18n-core'
gem 'washbullet'

group :production do
  gem 'foreman', '0.85.0'
end

install_if -> { ENV['DISABLE_SPRING'] == '1' && ENV['RAILS_ENV'] == 'production' } do
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  gem 'filewatcher'
end
