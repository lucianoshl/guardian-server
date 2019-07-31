# frozen_string_literal: true

describe TroopModel do
  it 'test model fields' do
    expect(Unit.ids).not_to be_empty
    model_file = Dir['./**/models/troop_model.rb'].first
    load model_file
    require model_file
    TroopModel.new(spear: 1)
  end
end
