# frozen_string_literal: true

class InvitedPlayerException < RuntimeError
  attr_accessor :expiration

  def initialize(message)
    raw_date = message.scan(/\d.+,/).first.gsub(/[,()]/, '')
    self.expiration = Time.strptime(raw_date, '%d/%b/%Y  %H:%M')
  end
end
