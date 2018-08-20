# frozen_string_literal: true

require 'logger'

module Logging
  class << self
    def logger
      @logger ||= Logger.new($stdout)
      # @logger.formatter = proc do |_severity, _datetime, _progname, msg|
      #   "#{msg}\n"
      # end
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
