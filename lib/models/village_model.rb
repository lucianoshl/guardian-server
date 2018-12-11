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
      { wall: 1 },
      { hide: 3 },
      { wood: 5, stone: 5 },
      { market: 1 },
      { main: 7, barracks: 5 },
      { main: 10, smith: 5, stable: 1 },
      { stable: 3 },
      { wood: 9, stone: 9, wall: 5 },
      { barracks: 7, market: 5 },
      { wood: 12, iron: 8 },
      { main: 12, wall: 10 },
      { stone: 12, iron: 10 },
      { main: 15, smith: 10 },
      { garage: 1, market: 10 },
      { barracks: 15, wood: 16, stone: 16, iron: 16 },
      { main: 20, smith: 20 },
      { wood: 20, stone: 20 }
    ].map { |a| Buildings.new(a) }

    model.train = TroopModel.new(spear: 4000, sword: 4000, spy: 1000, light: 20, ram: 200)

    model
  end
end
