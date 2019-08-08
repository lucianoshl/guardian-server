# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'coveralls/rake/task'

Rails.application.load_tasks

Coveralls::RakeTask.new
task :test_with_coveralls => [:spec, :features, 'coveralls:push']