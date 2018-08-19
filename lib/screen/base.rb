# frozen_string_literal: true

class Screen::Base < Screen::Logged
  include Screen::Parser

  attr_accessor :quests, :server_time, :player, :village

  def initialize(args = {})
    super
  end

  def parse(page)
    game_data = parse_json_argument(page,'TribalWars.updateGameData')
    self.server_time = parse_server_time(page)
    self.player = parse_player(page,game_data)
    self.village = parse_village(page,game_data)
  end

  def parse_server_time(page)
    time_server_str = "#{page.search('#serverDate').text} #{page.search('#serverTime').text}"
    Time.parse time_server_str
  end

  def parse_player(page,game_data)
    player_json = game_data['player'].select_keys(:id,:name,:rank,:points)
    player_json[:id] = player_json[:id].to_i
    Player.new(player_json)
  end

  def parse_village(page,game_data)
    village = Village.new(game_data['village'].select_keys(:id,:name,:x,:y))
    village
  end
end
