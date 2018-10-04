# frozen_string_literal: true

module MongoInflector
  def field_name(name)
    name == '_id' ? 'id' : name
  end

  def field_type(name, meta, types)
    return types.ID if name == '_id'
    return types.String if meta.type == String
    return types.Int if meta.type == Integer
    return types.Float if meta.type == Float
    return nil if meta.type == Hash
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

module Type::Base
  @@mapping = {}

  def self.hash
    @@mapping
  end

  def self.register_type(graphqlType, mongoType)
    @@mapping[mongoType] = graphqlType
  end

  def self.get_graphql_type(mongoType)
    @@mapping[mongoType]
  end

  def self.included(base)
    class << base
      include MongoInflector
      @mutations = []

      def definition
        this = self
        @target = target = class_base

        Type::Base.register_type(self, target)

        if @definition.nil?
          @definition = GraphQL::ObjectType.define do
            name this.definition_name
            description "Generated model for class #{this.to_s.gsub('Type::', '')}"

            fields = target.fields.merge(target.relations)

            fields.map do |name, meta|
              field_type = this.field_type(name, meta, types)
              field(this.field_name(name), field_type) unless field_type.nil?
            end
          end
        end
        @definition
      end

      def input_type
        this = self
        @target = target = class_base
        if @input_type.nil?
          @input_type = GraphQL::InputObjectType.define do
            name("#{this.to_s.gsub('Type::', '')}Input")
            fields = target.fields

            fields.map do |name, meta|
              field_type = this.field_type(name, meta, types)
              argument(this.field_name(name), field_type) unless field_type.nil?
            end
          end
        end
        @input_type
      end

      def base_criteria(_obj, args, _ctx)
        base_fields = @target.fields.merge(@target.relations).keys << 'id'
        filters = args.to_h.select_keys(*base_fields)
        criteria = @target.where(filters)
        criteria = @criteria_block.call(criteria, args) unless @criteria_block.nil?
        criteria
      end

      def config(&block)
        @config_block = block unless block.nil?
        @config_block
      end

      def criteria(&block)
        @criteria_block = block unless block.nil?
        @criteria_block
      end

      def class_base(clazz = nil)
        if @class_base.nil?
          @class_base = clazz.nil? ? to_s.demodulize.constantize : clazz
        end
        @class_base
      end

      def definition_name(str = nil)
        if @definition_name.nil?
          @definition_name = str.blank? ? to_s.gsub('Type::', '') : str
        end
        @definition_name
      end

      def mutation(&block)
        @mutations = [] if @mutations.nil?
        @mutations << Class.new(GraphQL::Function) do
          def self.name(value = nil)
            @name = value unless value.nil?
            @name
          end

          class_eval &block
        end
      end

      def mutations
        @mutations = [] if @mutations.nil?
        @mutations
      end
    end
  end
end
