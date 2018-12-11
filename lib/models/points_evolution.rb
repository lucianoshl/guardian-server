# frozen_string_literal: true

class PointsEvolution
  include Mongoid::Document

  embedded_in :village
  field :ocurrence, type: Time, default: -> { Time.now }
  field :current, type: Integer
  field :diference, type: Integer
  field :causes, type: Array
end
