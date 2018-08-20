# frozen_string_literal: true

class NewbieProtectionException < RuntimeError
  attr_accessor :expiration

  def initialize(message)
    self.expiration = message.scan(/termina (.+)\./).first.first.to_datetime
  end
end
