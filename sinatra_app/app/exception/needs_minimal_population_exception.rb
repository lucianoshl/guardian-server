# frozen_string_literal: true

class NeedsMinimalPopulationException < RuntimeError
  attr_accessor :population

  def initialize(message)
    self.population = message.scan(/\d+/).first.to_i
  end
end
