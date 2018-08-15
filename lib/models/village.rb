# frozen_string_literal: true

class Village
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :points, type: Integer
  field :x, type: Integer
  field :y, type: Integer

  belongs_to :player, optional: true

  before_save
    
  end

  def distance other
    Math.sqrt ((self.x - other.x)**2 + (self.y - other.y)**2)
  end

  def merge_non_nil other
    hash_values = other.to_h
    hash_values.delete(:id)
    hash_values.map do |k,v|
      self[k] = v
    end
    self
  end
end