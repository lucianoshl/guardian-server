class Nokogiri::XML::NodeSet
  def parent_until &block
    element = self.first
    loop do
      element = element.parent
      break if (element.nil? || block.call(element))
    end
    element
  end
end