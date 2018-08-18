# frozen_string_literal: true

class Coordinate
  include Mongoid::Document
  include AbstractCoordinate

  def ==(other)
    other_methods = other.methods
    if other_methods.include?(:x) && other_methods.include?(:y)
      return self.x == other.x && self.y == other.y
    end
    false
  end

  def to_s
    "#{x}|#{y}"
  end
end