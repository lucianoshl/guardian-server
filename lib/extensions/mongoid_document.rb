# frozen_string_literal: true

module Mongoid::Document
  def store
    raise Exception, "Error saving #{self.class} : #{errors.to_a}" unless save
    self
  end

  def merge_non_nil(other)
    current_attrs = (self.class.fields.keys - ['_id'] + ['id']).map(&:to_sym)
    hash_values = other.to_h

    hash_values = hash_values.select_keys(*current_attrs).reject { |_k, v| v.nil? }

    hash_values.delete(:id)
    hash_values.map do |k, v|
      self[k] = v
    end
    self
  end

  def save_if_not_saved
    store if self.class.where(id: id).count.zero?
  end
end
