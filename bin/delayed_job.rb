# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'delayed/command'
Delayed::Worker.max_run_time = 10.minutes
Delayed::Worker.logger = Rails.logger
Delayed::Worker.backend = :mongoid

worker_args = ARGV[1..-1]

queue_name = ARGV.select { |a| a =~ /--queue=/ }.first.scan(/--queue=(.+)/).first.first

if ENV['ENV'] == 'production'
  Delayed::Backend::Mongoid::Job.where(queue: queue_name).map do |job|
    job.unlock
    job.save
  end
end


disable_spring = ENV['DISABLE_SPRING'] == '1'

if disable_spring
  command = Delayed::Command.new(worker_args)
  Delayed::Worker.before_fork
  command.run
else
  Delayed::Command.new(worker_args).daemonize
end
