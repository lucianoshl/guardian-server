Mongoid.logger = Logger.new(STDOUT)
Mongoid.logger.level = -1

Mongoid.load!("#{File.dirname(__FILE__)}/../../config/mongoid.yml")