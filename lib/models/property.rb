# frozen_string_literal: true

class Property
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key, type: String
  field :value, type: String

  def self.put(key, value)
    find_or_create(key).fill(key, value).store
  end

  def self.get(key, default_value = nil)
    prop = find_or_create(key)
    return put(key, default_value).deserialize unless prop.persisted?
    prop.deserialize
  end

  def self.find_or_create(key)
    Property.where(key: key).first || Property.new
  end

  def fill(key, value)
    self.key = key
    self.value = value.nil? ? nil : YAML.dump(value)
    self
  end

  def deserialize
    value.nil? ? nil : YAML.safe_load(value, [Symbol, OpenStruct])
  end
end
