# frozen_string_literal: true

current_folder = File.dirname(__FILE__)

require_rel '../util/logging.rb'
include Logging

Thread.new do
  Filewatcher.new("#{current_folder}/..").watch do |filename, _event|
  	logger.debug("Reloading file #{filename}")
    load filename
  end
end
