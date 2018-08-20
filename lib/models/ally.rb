# frozen_string_literal: true

class Ally
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :points, type: Integer
  field :short, type: Integer

  has_many :players
end
