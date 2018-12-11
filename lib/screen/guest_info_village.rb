# frozen_string_literal: true

class Screen::GuestInfoVillage < Screen::Guest
  entry 'guest.php'
  screen :info_village

  attr_accessor :village

  def initialize(args = {})
    super
  end

  def parse(page)
    main_table = page.search('#minimap_viewport').parent_until{|a| a.name=='table'}
    coordinate = main_table.search('tr:eq(3)').text.to_coordinate

    self.village = v = Village.new
    
    v.id = page.body.scan(/VillageInfo.village_id = (\d+)/).number_part
    v.name = page.search('h2').text
    v.points = main_table.search('tr:eq(4)').text.number_part
    v.player_id = page.body.scan(/VillageInfo.player_id = (\d+)/).number_part
    v.x = coordinate.x
    v.y = coordinate.y
  end


end
