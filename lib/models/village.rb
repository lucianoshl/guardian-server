# frozen_string_literal: true

class Village
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :points, type: Integer
  field :x, type: Integer
  field :y, type: Integer

  belongs_to :player
end