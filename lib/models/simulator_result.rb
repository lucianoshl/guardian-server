# frozen_string_literal: true

class SimulatorResult
  include Mongoid::Document
  field :key, type: String
  field :win, type: Boolean
end
