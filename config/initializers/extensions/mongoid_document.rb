# frozen_string_literal: true

module Mongoid::Document
  def store
    raise Exception, "Error saving #{self.class} : #{errors.to_a}" unless save

    self
  end

  def field_keys
    (self.class.fields.keys - ['_id'] + ['id']).map(&:to_sym)
  end

  def merge_non_nil(other)
    hash_values = other.to_h.select_keys(field_keys).reject { |_k, v| v.nil? }
    merge_properties(hash_values)
  end

  def merge_properties(other)
    hash_values = other.to_h.deep_symbolize_keys
    intersection_fields = (hash_values.keys & field_keys) & hash_values.keys
    hash_values.delete(:id)
    intersection_fields.delete(:id)
    intersection_fields.map do |k|
      self[k] = hash_values[k]
    end
    self
  end

  def save_if_not_saved
    store if self.class.where(id: id).count.zero?
  end
end
