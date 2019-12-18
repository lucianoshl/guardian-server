# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

if Rails.env.test?
  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
  task test_with_coveralls: [:spec, :features, 'coveralls:push']
end

if Rails.env.development?
  desc 'Copy production db to dev db'
  task :copydb do
    config = YAML.safe_load(File.read("#{Rails.root}/config/application.yml"))
    prd_mongo = config['production']['MONGO_URL']
    `mongodump --uri=#{prd_mongo} --gzip --archive > dump.gz`
    `mongorestore --drop --gzip --archive=dump.gz --nsFrom "guardian-tenant-01.*" --nsTo "guardian-dev.*"`
    `rm dump.gz`
  end
end
