# frozen_string_literal: true

class Command::Abstract
  include Mongoid::Document

  field :arrival, type: Time
  field :create_at, type: Time

  belongs_to :origin, class_name: Village.to_s
  belongs_to :target_village, class_name: Village.to_s
  embeds_one :target, class_name: Coordinate.to_s
end
