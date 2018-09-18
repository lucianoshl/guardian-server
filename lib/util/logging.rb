# frozen_string_literal: true

require 'logger'

module Logging
  class << self
    def logger
      if @logger.nil?
        @logger ||= Logger.new($stdout)
        @logger.level = "Logger::#{Enviroment['log']['level']}".constantize
        @logger.formatter = proc do |_severity, _datetime, _progname, _msg|
          eval('"' + Enviroment['log']['format'] + '"')
        end
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
