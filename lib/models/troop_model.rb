# frozen_string_literal: true

class TroopModel < Troop
  include Mongoid::Document

  Unit.ids.map do |id|
    fields.delete(id)
    field id.to_sym, type: Float, default: 0
  end

  def inspect
    "#{self.class.name} #{to_h.select { |_unit, qte| qte > 0 }}".gsub('"', '')
  end
end
