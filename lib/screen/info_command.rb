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
      self.command = Command::Incoming.new
      command.id = page.uri.to_s.scan(/id=(\d+)/).number_part
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
    possible_units = times.select{|a| a.seconds > seconds_to_arrival }
    max = possible_units.max{|a| a.diference}.diference
    possible_units.select{|a| a.diference == max}.map(&:unit)
  end
end
