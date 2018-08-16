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
end