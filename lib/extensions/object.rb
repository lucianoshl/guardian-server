class Object
  def number_part
    self.to_s.scan(/\d+/).join().to_i
  end
end