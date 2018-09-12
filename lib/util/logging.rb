# frozen_string_literal: true

require 'logger'

module Logging
  class << self
    def logger
      @logger ||= Logger.new($stdout)
      @logger.level = Logger::DEBUG
      logger_format = Enviroment['logger_format'].nil?
      if logger_format.nil?
        @logger.formatter = Logger::Formatter.new
      else
        @logger.formatter = proc do |_severity, _datetime, _progname, msg|
          binding.pry
          "#{Enviroment['logger_format']}#{msg}\n"
        end
      end
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
