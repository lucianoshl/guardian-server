# frozen_string_literal: true

class Screen::Base < Screen::Logged
  include Screen::Parser

  attr_accessor :quests, :server_time

  def initialize
    super
  end

  def parse(page)
    time_server_str = "#{page.search('#serverDate').text} #{page.search('#serverTime').text}"
    self.server_time = Time.parse time_server_str
    self.quests = parse_json_argument(page, 'Quests.setQuestData').values.map { |a| Quest.new(a) }
  end
end
