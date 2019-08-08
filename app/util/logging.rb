# frozen_string_literal: true

require 'logger'

module Logging
  
  def self.included(base)
    class << base
      def logger
        Rails.logger
      end
    end
  end

  def logger
    Rails.logger
  end
end
