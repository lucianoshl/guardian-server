module Enviroment

  @@configs = nil

  def self.[](index)
    configs[ENV['ENV']][index]
  end

  def self.configs
    if @@configs.nil?
      config_location = "#{File.dirname(__FILE__)}/../../config/env.yml"
      @@configs = YAML.load(File.read(config_location))
    end
    @@configs
  end
end