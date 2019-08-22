# frozen_string_literal: true

class VillageModel
  include Mongoid::Document

  field :name, type: String
  embeds_many :buildings, class_name: Buildings.to_s
  embeds_one :train, class_name: TroopModel.to_s

  def self.basic_model
    yaml_configs['FIRST_VILLAGE']
  end

  def self.yaml_configs
    yaml = YAML.safe_load(File.read("#{Rails.root}/config/model/village.yml"), [], [], true)
    converted = yaml.map do |name,config|
      item = VillageModel.new
      item.name = name.upcase
      item.buildings = config['buildings'].flatten.map { |a| Buildings.new(a) }
      item.train = TroopModel.new(config['train'])
      [item.name,item]
    end
    converted.to_h
  end
end
