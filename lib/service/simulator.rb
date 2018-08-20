# frozen_string_literal: true

class Service::Simulator

  include Logging

  def self.run(attack,defence:Troop.new,wall:0,moral:100)
  	key = [attack.to_a.to_s,defence.to_a.to_s,wall.to_s,moral.to_s].join(' ')
  	return Cachy.cache(key) do 
	    screen = Screen::Simulator.new
	    screen.simulate(attack,defence,wall,moral)
	    screen.atk_looses.total.zero?
  	end
  end

end
