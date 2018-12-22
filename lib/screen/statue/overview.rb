# frozen_string_literal: true

class Screen::Statue::Overview < Screen::Base
  screen :statue
  mode :overview

  attr_accessor :slots, :knights_data, :builded

  def parse(page)
    super
    json = page.body.scan(/BuildingStatue.receiveKnightsData\(\[.*\], ({(?:.+)})/).flatten.first
    self.builded = !json.nil?
    self.knights_data = JSON.parse(json) if builded
  end


end
