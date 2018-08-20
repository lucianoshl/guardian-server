# frozen_string_literal: true

module AbstractCoordinate
  def self.included(base)
    base.field :x, type: Integer
    base.field :y, type: Integer
    base.define_method(:distance) do |other|
      Math.sqrt ((x - other.x)**2 + (y - other.y)**2)
    end
  end
end
