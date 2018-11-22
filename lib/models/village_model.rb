# frozen_string_literal: true

class VillageModel
  include Mongoid::Document

  field :name, type: String
  embeds_many :buildings, class_name: Buildings.to_s
  embeds_one :train, class_name: TroopModel.to_s

  def self.basic_model
    model = VillageModel.new

    model.name = 'BASIC'
    model.buildings = [
      { wood: 1 },
      { stone: 1, iron: 1 },
      { wood: 2, stone: 2 },
      { main: 2 },
      { main: 3, barracks: 1 },
      { wood: 3, stone: 3, barracks: 2 },
      { storage: 2 },
      { iron: 2, storage: 3 },
      { barracks: 3 },
      { statue: 1 },
      { farm: 2, iron: 3 },
      { main: 5, smith: 1 },
      { wood: 4, stone: 4 },
      { storage: 2 },
      { iron: 2, storage: 3 },
      { statue: 1 },
      { iron: 3, farm: 2 },
      { storage: 20 }
    ].map { |a| Buildings.new(a) }

    model.train = TroopModel.new(spear: 40)

    model
  end
end
