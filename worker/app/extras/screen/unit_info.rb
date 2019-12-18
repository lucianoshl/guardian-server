# frozen_string_literal: true

class Screen::UnitInfo < Screen::Base
  screen :unit_info

  attr_accessor :json

  def initialize
    super(ajax: 'data')
  end

  def parse(page)
    self.json = JSON.parse(page.body)
  end
end
