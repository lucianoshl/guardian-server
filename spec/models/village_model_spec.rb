# frozen_string_literal: true

describe VillageModel do
  it 'read models from config file' do
    configs = VillageModel.yaml_configs
    expect(configs.size).to eq(4)
  end

  it 'check basic model' do
    expect(Village.basic_model.name).to eq('FIRST_VILLAGE')
  end
end
