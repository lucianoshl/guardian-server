# frozen_string_literal: true

Types.const_set(:MongoTypes, [Village, Player, Report, Resource, Troop])

def field_map(name, field, types)
  map = {}
  map[BSON::ObjectId] = types.ID
  map[Integer] = types.Int
  map[Time] = Types::DateTimeType
  map[DateTime] = Types::DateTimeType
  map[String] = types.String
  map[Mongoid::Boolean] = types.Boolean

  from_hash = map[field.options[:type]]
  return [name, from_hash] unless from_hash.nil?

  if field.class == Mongoid::Fields::ForeignKey
    final_name = field.metadata[:name].to_s
    class_name_raw = field.options[:metadata].class_name || field.options[:metadata].name
    class_name = class_name_raw.to_s.camelize.constantize
    final_class = Types.const_get(class_name.to_s)

    return nil if final_class.class == Class

    return [final_name, final_class]
  end

  if field.class == Mongoid::Relations::Metadata && [Mongoid::Relations::Referenced::In, Mongoid::Relations::Embedded::One].include?(field[:relation])
    final_name = field.name.to_s
    class_name = (field[:class_name] || field[:name]).to_s.camelize.constantize
    final_class = Types.const_get(class_name.to_s)

    return nil if final_class.class == Class

    return [final_name, final_class]
  end

  if field.class == Mongoid::Relations::Metadata && [Mongoid::Relations::Embedded::Many, Mongoid::Relations::Referenced::Many].include?(field[:relation])
    final_name = field.name.to_s

    class_name = (field[:class_name] || field[:name].to_s.singularize).to_s.camelize.constantize
    final_class = Types.const_get(class_name.to_s)

    return nil if final_class.class == Class

    return [final_name, types[final_class]]
  end

  if field.class == Mongoid::Relations::Metadata && [Mongoid::Relations::Embedded::In].include?(field[:relation])
    return nil
  end

  binding.pry

  # key = field.options[:type]
  # if key == Object
  #   target_name =
  #   key = target_name.to_s.camelize.constantize
  # end

  # return types.ID if key == BSON::ObjectId

  # result = map[key]
  # return result unless result.nil?

  # result =  Types.const_get(key.to_s)
  # return nil if result.class != GraphQL::ObjectType

  # puts "not defined for #{key}" if result.nil?
  # return result
end

Types::MongoTypes.map do |model|
  object_type = GraphQL::ObjectType.define do
    name model.to_s
    description "Representation of #{model} in guardian"
    model.fields.merge(model.relations).map do |name, field|
      target_field = field_map(name, field, types)
      puts "type #{field.options[:type]} not mapped in GraphQL" if target_field.nil?
      field(target_field.first, target_field.last) unless target_field.nil?
    end
  end
  Types.const_set(model.to_s, object_type)
end
