# frozen_string_literal: true

class Coordinate
  include Mongoid::Document
  include AbstractCoordinate

  def ==(other)
    other_methods = other.methods
    return x == other.x && y == other.y if other_methods.include?(:x) && other_methods.include?(:y)
    false
  end

  def to_s
    "#{x}|#{y}"
  end

  def to_h
    result = attributes.clone
    result.delete '_id'
    result
  end
end
