# frozen_string_literal: true

require 'bundler/setup'
require 'delayed/command'
Bundler.require(:default, ENV['ENV'])

require_rel '../app/requirer.rb'

Delayed::Worker.max_run_time = 10.minutes
Delayed::Worker.logger = Logging.logger
Delayed::Worker.backend = :mongoid

queue_name = ARGV.select { |a| a =~ /--queue=/ }.first.scan(/--queue=(.+)/).first.first

if ENV['ENV'] == 'production'
  Delayed::Backend::Mongoid::Job.where(queue: queue_name).map do |job|
    job.unlock
    job.save
  end
end

Delayed::Command.new(ARGV).daemonize
