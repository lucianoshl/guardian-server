# frozen_string_literal: true

require 'logger'

module Logging
  class << self
    def logger
      @logger ||= Logger.new($stdout)
      @logger.level = Logger::DEBUG
      @logger.formatter = proc do |severity, datetime, _progname, msg|
        eval('"' + Enviroment['logger_format'] + '"')
      end
      @logger
    end

    attr_writer :logger
  end

  # Addition
  def self.included(base)
    class << base
      def logger
        Logging.logger
      end
    end
  end

  def logger
    Logging.logger
  end
end
