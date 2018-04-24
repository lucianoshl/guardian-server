# frozen_string_literal: true

$DEBUG = true

require_rel './extensions'
require_rel './initializers'
require_rel './graphql_model'

Dir.glob("#{File.dirname(__FILE__)}/models/*").map do |folder|
  autoload_rel folder, base_dir: folder
end
