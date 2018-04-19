# frozen_string_literal: true

require 'bundler/setup'
require 'delayed/command'
Bundler.require(:default, ENV['ENV'])
require 'irb'

require_rel '../lib/requirer.rb'

ARGV.clear # otherwise all script parameters get passed to IRB
IRB.start
