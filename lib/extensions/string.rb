# frozen_string_literal: true

class String
  def underscore
    to_s.gsub(/::/, '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
  end

  def number_part
    self.scan(/\d+/).join().to_i
  end
end
