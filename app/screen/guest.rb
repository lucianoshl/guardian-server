# frozen_string_literal: true

class Screen::Guest < Screen::Abstract
  def initialize(args = {})
    @client = Client::Desktop.new
    super
  end
end
