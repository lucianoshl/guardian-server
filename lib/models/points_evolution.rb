# frozen_string_literal: true

class PointsEvolution
  include Mongoid::Document

  field :ocurrence, type: DateTime, default: -> { Time.now }
  field :current, type: Integer
  field :diference, type: Integer
  field :causes, type: Array
end
