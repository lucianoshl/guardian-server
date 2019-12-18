# frozen_string_literal: true

class Resource
  include Mongoid::Document

  field :wood, type: Integer, default: 0
  field :stone, type: Integer, default: 0
  field :iron, type: Integer, default: 0

  embedded_in :resourcesable, polymorphic: true

  after_initialize do
    self.wood ||= 0
    self.stone ||= 0
    self.iron ||= 0
  end

  def total
    wood + stone + iron
  end

  def sum
    total
  end

  def self.parse(obj)
    if !obj.search('#wood').empty?
      element = obj.search('#wood').first
      wood = element.nil? ? 0 : element.number_part
      element = obj.search('#stone').first
      stone = element.nil? ? 0 : element.number_part
      element = obj.search('#iron').first
      iron = element.nil? ? 0 : element.number_part
    else
      element = obj.search('.wood')
      wood = element.first.nil? ? 0 : element.first.parent.number_part
      element = obj.search('.stone')
      stone = element.first.nil? ? 0 : element.first.parent.number_part
      element = obj.search('.iron')
      iron = element.first.nil? ? 0 : element.first.parent.number_part
    end

    new wood: wood, stone: stone, iron: iron
  end

  def include?(other)
    !(self - other).has_negative?
  end

  def *(other)
    result = clone
    result.wood *= other
    result.stone *= other
    result.iron *= other
    result
  end

  def /(other)
    result = OpenStruct.new clone.to_h
    result.wood /= other
    result.stone /= other
    result.iron /= other
    result
  end

  def +(other)
    result = clone
    result.wood += other.wood
    result.stone += other.stone
    result.iron += other.iron
    result
  end

  def -(other)
    result = clone
    result.wood -= other.wood
    result.stone -= other.stone
    result.iron -= other.iron
    result
  end

  def to_h
    { wood: wood, stone: stone, iron: iron }
  end

  def has_negative?
    wood < 0 || stone < 0 || iron < 0
  end

  def has_positive?
    wood >= 0 || stone >= 0 || iron >= 0
  end

  def to_html
    %(
      <div>
        <span class="nowrap">
          <span class="icon header wood"></span>
          <span class="value">#{wood}</span>
        </span>
        <span class="nowrap">
          <span class="icon header stone"></span>
          <span class="value">#{stone}</span>
        </span>
        <span class="nowrap">
          <span class="icon header iron"></span>
          <span class="value">#{iron}<span>
        </span>
      </div>
    )
  end
end

class Hash
  def to_resource
    hash = with_indifferent_access
    result = Resource.new
    result.wood = hash['wood']
    result.stone = hash['stone']
    result.iron = hash['iron']
    result
  end
end

class Array
  def to_resource
    result = Resource.new
    result.wood = self[0]
    result.stone = self[1]
    result.iron = self[2]
    result
  end
end
