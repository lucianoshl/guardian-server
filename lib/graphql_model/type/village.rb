# frozen_string_literal: true

module Type::Village
  include Type::Base

  config do
    argument :id, types.Int
  end

  mutation do
    name 'UpdateDisableRecruit'
    argument :id, !types.Int
    argument :disabled, !types.Boolean
    type Type::Village.definition

    def call(object, inputs, ctx)
      village = Village.find(id: inputs['id'])
      village.disable_recruit = inputs['disabled']
      village.save
      village
    end
  end
end
