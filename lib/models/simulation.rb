# frozen_string_literal: true

class Simulation
  include Mongoid::Document

  embeds_one :atk_troops, class_name: Troop.to_s
  embeds_one :atk_looses, class_name: Troop.to_s
  embeds_one :def_troops, class_name: Troop.to_s
  embeds_one :def_looses, class_name: Troop.to_s

  def win
    atk_looses.total.zero?
  end

  def ==(other)
    self.atk_troops == other.atk_troops &&
    self.atk_looses == other.atk_looses &&
    self.def_troops == other.def_troops &&
    self.def_looses == other.def_looses
  end
end
