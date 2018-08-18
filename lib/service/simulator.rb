# frozen_string_literal: true

class Service::Simulator

  include Logging

  def self.run(attack,defence=Troop.new,wall=0,moral=100)
    screen = Screen::Simulator.new
    screen.simulate(attack,defence,wall,moral)
    screen.atk_looses.total.zero?
  end

end
