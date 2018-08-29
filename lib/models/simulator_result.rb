class SimulatorResult
  include Mongoid::Document
  field :key, type: String
  field :win, type: Boolean
end