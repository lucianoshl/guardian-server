# frozen_string_literal: true

module VillageHelper
  def create_village(model: VillageModel.basic_model)
    village = double('village')
    allow(village).to receive(:id).and_return 1
    allow(village).to receive(:points).and_return 3000
    allow(village).to receive(:disable_build).and_return false
    allow(village).to receive(:defined_model).and_return model
    village
  end
end
