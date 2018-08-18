class Nokogiri::XML::NodeSet
  def parent_until &block
    element = self.first
    loop do
      element = element.parent
      break if (element.nil? || block.call(element))
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