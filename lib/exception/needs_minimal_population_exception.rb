class NeedsMinimalPopulationException < Exception
  attr_accessor :population

  def initialize(message)
    self.population = message.scan(/\d+/).first.to_i
  end
end