# frozen_string_literal: true

class Client::Base < Mechanize
  include Logging

  def initialize
    super
    self.user_agent = [
      'Mozilla/5.0 (iPhone; CPU iPhone OS 12_3_1 like Mac OS X)',
      'AppleWebKit/605.1.15 (KHTML, like Gecko)',
      'Mobile/15E148 (Tribal Wars 2.10 rv:1560521892)'
    ].join(' ')
    @global_args = {}
    this = self
    ObjectSpace.define_finalizer(self, proc { this.shutdown })
  end
end
