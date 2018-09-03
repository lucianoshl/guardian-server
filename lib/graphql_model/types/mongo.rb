# frozen_string_literal: true

module MongoTypes
  include Logging

  @@types = {}

  def self.fix_id_field(field_name)
    field_name == '_id' ? 'id' : field_name
  end

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
      final_class = @@types[field.relation_class]

      return nil if final_class.nil?

      return [final_name, final_class]
    end

    if field.class == Mongoid::Relations::Metadata && [Mongoid::Relations::Embedded::Many, Mongoid::Relations::Referenced::Many].include?(field[:relation])
      final_name = field.name.to_s

      final_class = @@types[field.relation_class]

      return nil if final_class.nil?

      return [final_name, types[final_class]]
    end

    if field.class == Mongoid::Relations::Metadata && [Mongoid::Relations::Embedded::In].include?(field[:relation])
      return nil
    end

    # binding.pry
    return nil
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

          next if target_field.nil?
          field_name = MongoTypes.fix_id_field(target_field.first)
          field(field_name, target_field.last) do
            # if field.class == Mongoid::Relations::Metadata
            #   MongoTypes.generate_arguments(field.relation_class,types).map do |field_name,type|
            #     argument(field_name,type)
            #     binding.pry
            #     resolve ->(query, _args, _ctx) {
            #       filters = _args.argument_values.map do |k,v|
            #         v = v.value
            #         v = v.to_i if (k == 'id')
            #         [k,v]
            #       end
            #       field.relation_class.where(filters.to_h)
            #     }
            #   end
            # end
          end
        end
      end
    end
  end

  def self.generate_arguments(model, types)
    map = {}
    map[BSON::ObjectId] = types.ID
    map[Integer] = types.Int
    map[Time] = Types::DateTimeType
    map[DateTime] = Types::DateTimeType
    map[String] = types.String
    map[Mongoid::Boolean] = types.Boolean

    (model.fields.map do |name, field|
      type = map[field.options[:type]]
      [fix_id_field(name), type] unless type.nil?
    end).compact
  end

  def self.index
    @@types
  end
end

MongoTypes.build([Village, Player, Report, Resource, Troop, Delayed::Backend::Mongoid::Job, Task::Abstract])
