# frozen_string_literal: true

class Unit
  include Mongoid::Document

  field :id, type: String
  field :image, type: String
  field :type, type: String
  field :prod_building, type: String
  field :build_time, type: Integer
  field :wood, type: Integer
  field :stone, type: Integer
  field :iron, type: Integer
  field :pop, type: Integer
  field :speed, type: Float
  field :attack, type: Integer
  field :building_attack_multiplier, type: Integer
  field :additional_max_wall_negation, type: Integer
  field :defense, type: Integer
  field :defense_cavalry, type: Integer
  field :defense_archer, type: Integer
  field :carry, type: Integer
  field :stealth, type: Integer
  field :perception, type: Integer
  field :can_attack, type: Boolean
  field :can_support, type: Boolean
  field :attackpoints, type: Integer
  field :defpoints, type: Integer
  field :cost_modifier, type: Integer
  field :reqs, type: Array
  field :tech_costs, type: Hash
  field :name, type: String
  field :shortname, type: String
  field :desc, type: String
  field :desc_abilities, type: Array

  scope :attackers, ->{ nin(id: [:militia]) }

  after_upsert do
    troop_has_field = Troop.fields.key?(id)
    Troop.field id.to_sym, type: Integer, default: 0 unless troop_has_field
  end

  def self.get(id)
    Cachy.cache("unit_#{id}") do
      Unit.where(id: id).first
    end
  end

  def self.ids
    Unit.all.pluck(:id)
  end

  def equivalent(other, field)
    return 0 if other[field].zero?
    self[field].to_f / other[field]
  end

  def square_per_minutes
    (1.0 / (60 * speed))
  end
  
end
