# frozen_string_literal: true

class Screen::Logged < Screen::Abstract
  def initialize(args = {})
    @client = Client::Logged.new(Client::Mobile.new)
    super
  end
end
