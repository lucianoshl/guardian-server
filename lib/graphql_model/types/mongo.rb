# frozen_string_literal: true

module MongoTypes
  include Logging

  @@types = {}

  def self.field_map(name, field, types)
    map = {}
    map[BSON::ObjectId] = types.ID
    map[Integer] = types.Int
    map[Time] = Types::DateTimeType
    map[DateTime] = Types::DateTimeType
    map[String] = types.String
    map[Float] = types.Float
    map[Mongoid::Boolean] = types.Boolean

    from_hash = map[field.options[:type]]
    return [name, from_hash] unless from_hash.nil?

    if field.class == Mongoid::Fields::ForeignKey
      final_name = field.metadata[:name].to_s
      class_name_raw = field.options[:metadata].class_name || field.options[:metadata].name
      class_name = class_name_raw.to_s.camelize.constantize
      final_class = @@types[class_name]

      return nil if final_class.nil?

      return [final_name, final_class]
    end

    if field.class == Mongoid::Relations::Metadata && [Mongoid::Relations::Referenced::In, Mongoid::Relations::Embedded::One, Mongoid::Relations::Referenced::One].include?(field[:relation])
      final_name = field.name.to_s
      class_name = (field[:class_name] || field[:name]).to_s.camelize.constantize
      final_class = @@types[class_name]


      return nil if final_class.nil?

      return [final_name, final_class]
    end

    if field.class == Mongoid::Relations::Metadata && [Mongoid::Relations::Embedded::Many, Mongoid::Relations::Referenced::Many].include?(field[:relation])
      final_name = field.name.to_s

      class_name = (field[:class_name] || field[:name].to_s.singularize).to_s.camelize.constantize
      final_class = @@types[class_name]

      return nil if final_class.nil?

      return [final_name, types[final_class]]
    end

    if field.class == Mongoid::Relations::Metadata && [Mongoid::Relations::Embedded::In].include?(field[:relation])
      return nil
    end

    binding.pry
  end

  def self.build(models)
    models.map do |model|

      @@types[model] = GraphQL::ObjectType.define do
        logger.debug("Creating GraphQL model for #{model}")
        logger.debug("Available fields #{model.fields.merge(model.relations).keys}")

        name model.to_s.gsub('::', '_')
        description "Representation of #{model} in guardian"

        model.fields.merge(model.relations).map do |name, field|
          target_field = MongoTypes.field_map(name, field, types)
          puts "field #{name} not mapped in GraphQL" if target_field.nil?

          field(target_field.first, target_field.last) unless target_field.nil?
        end
      end
    end
  end

  def self.generate_arguments(model,types)
    map = {}
    map[BSON::ObjectId] = types.ID
    map[Integer] = types.Int
    map[Time] = Types::DateTimeType
    map[DateTime] = Types::DateTimeType
    map[String] = types.String
    map[Mongoid::Boolean] = types.Boolean

    (model.fields.map do |name,field|
      type = map[field.options[:type]]
      unless type.nil?
        [name,type]
      end
    end).compact
  end

  def self.index
    @@types
  end
end

MongoTypes.build([Village, Player, Report, Resource, Troop, Delayed::Backend::Mongoid::Job, Task::Abstract])
