module MongoInflector
  def field_name name
    name == '_id' ? 'id' : name
  end

  def field_type name,meta,types
    return types.ID if name == '_id' 
    return types.String if meta.type == String
    return types.Int if meta.type == Integer
    return nil if meta.class == Mongoid::Relations::Metadata && meta.relation == Mongoid::Relations::Embedded::In

    type = meta.type
    if type == Object && meta.options[:metadata]
      type = meta.options[:metadata].class_name.constantize
    elsif meta.class == Mongoid::Relations::Metadata || meta.polymorphic?
      type = meta.relation_class
    end

    return types.Boolean if [Boolean,Mongoid::Boolean].include? type
    return Type::DateTime.definition if  [DateTime,Time].include? type
    return nil if [Array,Account].include? type

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

  def self.register_type(graphqlType,mongoType)
    puts "#{graphqlType} registeread #{mongoType}"
    @@mapping[mongoType] = graphqlType
  end

  def self.get_graphql_type(mongoType)
    @@mapping[mongoType]
  end

  def self.included(base)

    class << base
      include MongoInflector
      def definition
        this = self
        @target = target = class_base

        Type::Base.register_type(self,target)

        @definition = GraphQL::ObjectType.define do

          name this.to_s.gsub('Type::','')
          description "Generated model for class #{this.to_s.gsub('Type::','')}"

          fields = target.fields.merge(target.relations)

          fields.map do |name,meta|
            field_type = this.field_type(name,meta,types)
            field(this.field_name(name),field_type) unless field_type.nil?
          end

        end if @definition.nil?
        @definition
      end

      def enabled?
        true
      end

      def base_criteria(obj, args, ctx)
        @target.where(args.to_h)
      end

      def config(&block)
        @config_block = block unless block.nil?
        @config_block 
      end

      def class_base(clazz = nil)
        if @class_base.nil?
          @class_base = clazz.nil? ? to_s.demodulize.constantize : clazz
        end
        @class_base 
      end
    end
  end

end