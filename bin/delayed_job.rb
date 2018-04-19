require 'bundler/setup'
require 'delayed/command'
Bundler.require(:default)

require_rel '../lib/requirer.rb'

Delayed::Worker.logger = Logger.new(STDOUT)
Delayed::Worker.logger.level = -1

Delayed::Worker.backend = :mongoid
Delayed::Command.new(ARGV).daemonize