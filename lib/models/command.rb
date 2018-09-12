# frozen_string_literal: true

class Command
  include Mongoid::Document

  field :arrival, type: DateTime
  field :returning, type: Boolean
  field :type, type: String

  belongs_to :origin, class_name: Village.to_s
  embeds_one :target, class_name: Coordinate.to_s
  embeds_one :troop
end
