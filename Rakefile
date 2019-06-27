# frozen_string_literal: true
# migrate this file to thor structure

require 'require_all'

ENV['ENV'] ||= 'development'
ENV['RACK_ENV'] = ENV['ENV'] || 'development'

require 'rubygems'
require 'bundler'
require 'bundler/setup'
Bundler.require(:default, ENV['ENV'] || 'development')
require_rel './lib/requirer.rb'
require 'rake'

namespace 'guardian' do
  desc 'Run webapp'
  task :server do
    ENV['PORT'] = ENV['PORT'] || '3000'
    Requirer.with_sub_folder_as_namespace('sinatra')
    require_rel './lib/sinatra/web_app.rb'
    Rack::Handler::WEBrick.run(WebApp,{ Host: '0.0.0.0', Port: ENV['PORT'] })
  end

  desc 'Run worker'
  task :worker do
    require 'delayed/command'
    Delayed::Worker.max_run_time = 10.minutes
    Delayed::Worker.logger = Logging.logger
    Delayed::Worker.backend = :mongoid

    worker_args = ARGV[2..-1]
    
    queue_name = ARGV.select { |a| a =~ /--queue=/ }.first.scan(/--queue=(.+)/).first.first
    
    if ENV['ENV'] == 'production'
      Delayed::Backend::Mongoid::Job.where(queue: queue_name).map do |job|
        job.unlock
        job.save
      end
    end
    
    Delayed::Command.new(worker_args).daemonize
  end

  desc 'Run console'
  task :console do
    require 'irb'
    ARGV.clear
    IRB.start
  end

  desc 'Run command'
  task :run do
    require 'bundler/setup'
    require 'delayed/command'
    Bundler.require(:default, ENV['ENV'])
    require_rel './lib/requirer.rb'
    eval("lambda{#{ARGV.last}}").call
    exit(0)
  end
end

if ENV['ENV'] == 'test'
  require 'rspec/core/rake_task'
  require 'coveralls/rake/task'
  desc 'Run RSpec'
  RSpec::Core::RakeTask.new do |t|
    t.verbose = false
  end
  task default: :spec
  Coveralls::RakeTask.new
end
