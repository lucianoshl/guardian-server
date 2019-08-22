# frozen_string_literal: true

module SimpleCov
  class << self
    attr_accessor :tested_file
  end

  def self.register_tested_file(file)
    tested_files << file
  end

  def self.tested_files
    self.tested_file ||= []
  end
end
