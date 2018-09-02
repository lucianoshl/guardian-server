# frozen_string_literal: true

class Screen::Base < Screen::Logged

  attr_accessor :quests, :server_time, :player, :village, :resources, :farm, :storage, :incomings

  def initialize(args = {})
    super
  end

  def parse(page)
    game_data = parse_json_argument(page, 'TribalWars.updateGameData')
    self.server_time = parse_server_time(page)
    self.player = parse_player(page, game_data)
    self.village = parse_village(page, game_data)
    self.resources = Resource.new(game_data['village'].select_keys(:wood,:stone,:iron))
    self.storage = parse_storage(page)
    self.farm = parse_farm(page)
    self.incomings = game_data['player']['incomings'].to_i
  end

  def parse_server_time(page)
    time_server_str = "#{page.search('#serverDate').text} #{page.search('#serverTime').text}"
    Time.parse time_server_str
  end

  def parse_player(_page, game_data)
    player_json = game_data['player'].select_keys(:id, :name, :rank, :points)
    player_json[:id] = player_json[:id].to_i
    Player.new(player_json)
  end

  def parse_village(_page, game_data)
    village = Village.new(game_data['village'].select_keys(:id, :name, :x, :y))
    village
  end

  def parse_farm(page)
    farm = OpenStruct.new
    farm.current = page.search('#pop_current_label').number_part
    farm.max = page.search('#pop_max_label').number_part
    farm.free = farm.max - farm.current
    farm.percent = farm.current.to_f/farm.max
    farm.warning = farm.percent > 0.8
    farm
  end

  def parse_storage(page)
    storage = OpenStruct.new
    storage.current = resources.to_h.values.max
    storage.max = page.search('#storage').number_part
    storage.free = storage.max - storage.current
    storage.percent = storage.current.to_f/storage.max
    storage.warning = storage.percent > 0.8
    storage
  end

  
end
