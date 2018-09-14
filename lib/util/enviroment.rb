# frozen_string_literal: true

module Enviroment
  @@configs = nil

  def self.[](index)
    configs[ENV['ENV']][index]
  end

  def self.configs
    if @@configs.nil?
      config_location = "#{File.dirname(__FILE__)}/../../config/env.yml"
      @@configs = YAML.safe_load(File.read(config_location), [], [], true)
    end
    @@configs
  end
end
