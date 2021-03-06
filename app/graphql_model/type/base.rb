# frozen_string_literal: true

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
        Type::Base.register_type(self, class_base)

        return @definition unless @definition.nil?

        @definition = GraphQL::ObjectType.define do
          class_base = this.class_base
          name this.definition_name
          description "Generated model for class #{this.to_s.gsub('Type::', '')}"

          fields = class_base.fields.merge(class_base.relations)

          fields.map do |name, meta|
            field_type = this.field_type(name, meta, types)
            field(this.field_name(name), field_type) unless field_type.nil?
          end
        end
      end

      def input_type
        this = self
        return @input_type unless @input_type.nil?

        @input_type = GraphQL::InputObjectType.define do
          name("#{this.to_s.gsub('Type::', '')}Input")
          fields = this.class_base.fields

          fields.map do |name, meta|
            field_type = this.field_type(name, meta, types)
            argument(this.field_name(name), field_type) unless field_type.nil?
          end
        end
      end

      def base_criteria(_obj, args, _ctx)
        base_fields = class_base.fields.merge(class_base.relations).keys << 'id'
        filters = args.to_h.select_keys(*base_fields)
        criteria = class_base.where(filters)
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
