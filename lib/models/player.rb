# frozen_string_literal: true

class Player
  include Mongoid::Document

  field :name, type: String
  field :points, type: Integer
  field :rank, type: Integer

  has_many :villages
  has_many :reports, inverse_of: 'target'

  belongs_to :account, optional: true
  belongs_to :ally, optional: true
end
