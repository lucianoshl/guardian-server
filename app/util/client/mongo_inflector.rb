# frozen_string_literal: true

module MongoInflector
  @@type_mapping = {}
  @@type_mapping[String] = GraphQL::STRING_TYPE
  @@type_mapping[Integer] = GraphQL::INT_TYPE
  @@type_mapping[Float] = GraphQL::FLOAT_TYPE
  @@type_mapping[Hash] = Type::Hash.definition

  def field_name(name)
    name == '_id' ? 'id' : name
  end

  def field_type(name, meta, types)
    return types.ID if name == '_id'

    result = @@type_mapping[meta.type]
    return result if @@type_mapping.key?(meta.type)

    return nil if meta.class == Mongoid::Relations::Metadata && meta.relation == Mongoid::Relations::Embedded::In

    type = meta.type
    if type == Object && meta.options[:metadata]
      type = meta.options[:metadata].class_name.constantize
    elsif meta.class == Mongoid::Relations::Metadata || meta.polymorphic?
      type = meta.relation_class
    end

    return types.Boolean if [Boolean, Mongoid::Boolean].include? type
    return Type::Time.definition if [Time].include? type
    return Type::Yaml.definition if Array == type
    return nil if Account == type

    graphql_type = Type::Base.get_graphql_type(type)
    if graphql_type.nil?
      binding.pry
    else
      definition = graphql_type.definition
      meta.is_list? ? types[definition] : definition
    end
  end
end
