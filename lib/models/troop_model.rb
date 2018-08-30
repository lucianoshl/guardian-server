# frozen_string_literal: true

class TroopModel
  include Mongoid::Document

  Unit.ids.map do |id|
    field id.to_sym, type: Float, default: 0
  end

  def each(&block)
    attrs = attributes.clone
    attrs.delete('_id')
    attrs.map(&block)
  end
end
