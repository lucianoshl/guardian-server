# frozen_string_literal: true

module Mongoid::Document
  def store
    save
    self
  end

  def merge_non_nil other
    current_attrs = (self.class.fields.keys -  ['_id'] + ['id']).map(&:to_sym)
    hash_values = other.to_h

    hash_values = hash_values.select_keys(*current_attrs).select{|k,v| !v.nil?}

    hash_values.delete(:id)
    hash_values.map do |k,v|
      self[k] = v
    end
    self
  end
end
