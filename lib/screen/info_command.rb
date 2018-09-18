# frozen_string_literal: true

class Screen::InfoCommand < Screen::Base
  screen :info_command

  attr_accessor :command

  def parse(page)
    table = parse_table(page,'#content_value > table')
    origin, target = page.search('.village_anchor[data-id]').map do |a| 
      r = OpenStruct.new
      r.id = a.attr('data-id').to_i
      r.coordinate = a.text.extract_coordinate
      r
    end

    incoming = Account.main.player.villages.map(&:id).include? target.id
    
    if incoming
      target_village = Village.find(target.id)
      self.command = Command::Incoming.new
      command.arrival = table[4].search('td').last.text.to_datetime
      command.create_at = Time.now
      command.origin_id = origin.id
      command.target = target.coordinate
      command.possible_troop = define_possible_troop(command)
    end
  end


  def define_possible_troop(command)
    seconds_to_arrival = command.arrival.to_i - command.create_at.to_i
    distance = command.origin.distance(command.target)
    times = Unit.attackers.map do |a|
      r = OpenStruct.new
      r.seconds = a.square_per_minutes * distance * 60
      r.diference = seconds_to_arrival - r.seconds
      r.unit = a.id
      r
    end
    times.select{|a| a.diference.positive? }.map(&:unit)
  end
end
