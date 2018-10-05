# frozen_string_literal: true

class NotPossibleAttackBeforeIncomingException < RuntimeError
  attr_accessor :incoming_time

  def initialize(time)
    self.incoming_time = time
  end
end
