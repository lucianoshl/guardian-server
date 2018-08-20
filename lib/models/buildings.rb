# frozen_string_literal: true

class Buildings
  include Mongoid::Document
  include Mongoid::Timestamps

  Building.ids.map do |id|
    field id.to_sym, type: Integer, default: 0
  end
end
