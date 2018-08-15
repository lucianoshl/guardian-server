class Array
  def to_index(&block)
    (self.map do |item|
      [block.call(item),item]
    end).to_h
  end
end