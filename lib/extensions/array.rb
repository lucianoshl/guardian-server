class Array
  def to_index(&block)
    (self.map do |item|
      [block.call(item),item]
    end).to_h
  end

  def pmap
    parameter = 3
    Parallel.map(self, in_threads: parameter || 1){ |i| yield(i) }
  end

  def to_troops
    units = Unit.ids
    Exception.new('Invalid array size') if units.size != self.size
    result = Troop.new
    units.each do |unit|
      result[unit] = self[units.index(unit)]
    end
    result
  end
end