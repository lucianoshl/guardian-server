# frozen_string_literal: true

def require_with_base_folder_as_namespace(folder)
  base_folder = "#{File.dirname(__FILE__)}/#{folder}/"
  Dir.glob("#{base_folder}/*").map do |file|
    autoload_rel file, base_dir: base_folder
  end
end

require_rel './extensions'
require_rel './initializers'
# require_rel './graphql_model'

require_with_base_folder_as_namespace('screen')

Dir.glob("#{File.dirname(__FILE__)}/models/*").map do |folder|
  autoload_rel folder, base_dir: folder
end

Dir.glob("#{File.dirname(__FILE__)}/util/*").map do |folder|
  autoload_rel folder, base_dir: folder
end
