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
    atk_troops == other.atk_troops &&
      atk_looses == other.atk_looses &&
      def_troops == other.def_troops &&
      def_looses == other.def_looses
  end
end
