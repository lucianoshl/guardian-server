class NewbieProtectionException < Exception
  attr_accessor :expiration

  def initialize(message)
    self.expiration = message.scan(/termina (.+)\./).first.first.to_datetime
  end
end