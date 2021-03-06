# frozen_string_literal: true

class Service::Simulator
  include Logging

  def self.win?(attack, defence: Troop.new, wall: 0, moral: 100)
    simulate(attack, defence: defence, wall: wall, moral: moral).win
  end

  def self.simulate(attack, defence: Troop.new, wall: 0, moral: 100)
    key = (attack.to_a + defence.to_a + [wall, moral]).join(',')

    logger.debug("Running simulator for #{attack}")

    result = SimulatorResult.where(key: key).first
    if result.nil?
      screen = Screen::Simulator.new
      screen.simulate(attack, defence, wall, moral)
      win = screen.atk_looses.total.zero?
      result = SimulatorResult.new(key: key, win: win)
      result.save
    else
      logger.debug("Reading from cache result is #{result.win}")
    end
    result
  end
end
