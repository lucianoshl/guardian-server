# frozen_string_literal: true

module Requirer
  def self.with_base_folder_as_namespace(folder)
    base_folder = "#{File.dirname(__FILE__)}/#{folder}/"
    Dir.glob("#{base_folder}/*").map do |file|
      # binding.pry if folder.include?('mutation')

      autoload_rel file, base_dir: base_folder
    end
  end

  def self.with_sub_folder_as_namespace(folder)
    Dir.glob("#{File.dirname(__FILE__)}/#{folder}/*").map do |element|
      autoload_rel element, base_dir: element
    end
  end

  def self.general
    require_rel './extensions'
    require_rel './initializers'
    require_rel './exception'

    Requirer.with_sub_folder_as_namespace('util')

    Requirer.with_base_folder_as_namespace('screen')
    Requirer.with_base_folder_as_namespace('event')
    Requirer.with_base_folder_as_namespace('service')
    Requirer.with_sub_folder_as_namespace('models')

    Requirer.with_sub_folder_as_namespace('graphql_model')

    # Requirer.with_base_folder_as_namespace('graphql_model/types')
    # require_rel './graphql_model/query.rb'
    # require_rel './graphql_model/mutation.rb'
    # require_rel './graphql_model/schema.rb'
  end
end

Requirer.general
