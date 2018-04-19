require 'bundler/setup'
require 'delayed/command'
Bundler.require(:default)
require 'irb'

require_rel '../lib/requirer.rb'

ARGV.clear # otherwise all script parameters get passed to IRB
IRB.start