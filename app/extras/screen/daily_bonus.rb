# frozen_string_literal: true

class Screen::DailyBonus < Screen::Base
  screen :info_player
  mode :daily_bonus

  attr_accessor :chests

  def initialize(args = {})
    super
  end

  def parse(page)
    super
    daily_bonus_data = parse_json_argument(page, 'DailyBonus.init')
    self.chests = daily_bonus_data['chests'].values.map(&:to_o)
  end

  def closed_chests
    chests.select{|a| !a.is_locked && !a.is_collected}
  end

  def open_chest(chest)
    args = {
      day: chest.day,
      from_screen: 'profile',
      h: csrf_token
    }
    headers = { 'with-hash': false }
    headers['Content-Type'] = 'application/x-www-form-urlencoded'
    
    @client.post("/game.php?village=#{village.id}&screen=daily_bonus&ajaxaction=open",args,headers)
    reload
  end
end

