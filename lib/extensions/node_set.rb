# frozen_string_literal: true

class Nokogiri::XML::NodeSet
  def parent_until
    element = first
    loop do
      element = element.parent
      break if element.nil? || yield(element)
    end
    element
  end

  def map_compact(&block)
    map(&block).compact
  end

  def select_index(list)
    list.map do |index|
      self[index]
    end
  end
end
