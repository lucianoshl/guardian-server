class Object
  def number_part
    self.to_s.scan(/\d+/).join().to_i
  end

  def to_coordinate
    x,y = scan(/(\d{3})\|(\d{3})/).flatten
    Coordinate.new(x: x.to_i, y: y.to_i)
  end
end