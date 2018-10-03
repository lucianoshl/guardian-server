# frozen_string_literal: true

class VillageModel
  include Mongoid::Document

  field :name, type: String
  embeds_many :buildings, class_name: Buildings.to_s
  embeds_one :train, class_name: TroopModel.to_s
end
