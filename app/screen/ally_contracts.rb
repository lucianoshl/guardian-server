# frozen_string_literal: true

class Screen::AllyContracts < Screen::Base
  screen :ally
  mode :contracts

  attr_accessor :allies_ids

  def parse(page)
    self.allies_ids = page.search('#content_value a').map do |a|
      href = a.attr('href')
      href.scan(/screen=info_ally&id=(\d+)/)
    end
    self.allies_ids = allies_ids.flatten.map(&:to_i)
  end
end
