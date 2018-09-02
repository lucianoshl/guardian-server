# frozen_string_literal: true

class TroopModel < Troop
  include Mongoid::Document

  Unit.ids.map do |id|
    fields.delete(id)
    field id.to_sym, type: Float, default: 0
  end
end
