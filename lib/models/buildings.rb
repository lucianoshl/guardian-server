# frozen_string_literal: true

class Buildings
  include Mongoid::Document
  include Mongoid::Timestamps

  Building.ids.map do |id|
    field id.to_sym, type: Integer, default: 0
  end

  def each(&block)
    attrs = attributes.clone
    attrs.delete('_id')
    attrs.map(&block)
  end

  def -(other)
    result = Buildings.new
    result.each do |key,value|
      result[key] = self[key] - value
    end
    result
  end

  def contains?(other)
    !(self - other).has_negative?
  end

  def has_negative?
    each do |name,qte| 
      return true if qte < 0
    end
    return false
  end
end
