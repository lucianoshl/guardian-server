# frozen_string_literal: true

class Array
  def to_index
    (map do |item|
      [yield(item), item]
    end).to_h
  end

  def pmap(parameter = nil)
    parameter |= 8
    Parallel.map(self, in_threads: parameter || 1) { |i| yield(i) }
  end

  def to_troops
    units = Unit.ids
    Exception.new('Invalid array size') if units.size != size
    result = Troop.new
    units.each do |unit|
      result[unit] = self[units.index(unit)]
    end
    result
  end
end
