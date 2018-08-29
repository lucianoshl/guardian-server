# frozen_string_literal: true

require 'bundler/setup'
require 'delayed/command'
Bundler.require(:default, ENV['ENV'])

require_rel '../lib/requirer.rb'

Delayed::Worker.logger = Logger.new(STDOUT)
Delayed::Worker.logger.level = -1

Delayed::Worker.backend = :mongoid

queue_name = ARGV.select{|a| a =~ /--queue=/}.first.scan(/--queue=(.+)/).first.first

Delayed::Backend::Mongoid::Job.where(queue: queue_name).map do |job|
  job.unlock
  job.save
end

Delayed::Command.new(ARGV).daemonize
