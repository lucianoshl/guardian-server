# frozen_string_literal: true

class Screen::Smith < Screen::Base
  screen :smith

  attr_accessor :researched_units

  def initialize(args = {})
    super
  end

  def parse(page)
    super
    self.researched_units = Troop.new
    page.search('a[class*=unit_sprite]').map do |item|
      unit = item.attr('href').scan(/unit=(.+)&/).first.first
      researched = item.attr('class').include?('cross') ? 0 : 1
      researched_units[unit] = researched
    end
  end

  def spy_is_researched?
    researched_units.spy == 1
  end
end
