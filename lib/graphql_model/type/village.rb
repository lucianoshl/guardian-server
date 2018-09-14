# frozen_string_literal: true

module Type::Village
  include Type::Base

  config do
    argument :id, types.Int
  end

  mutation do
    name 'UpdateDisableRecruit'

    input_field :id, !types.Int
    input_field :disabled, !types.Boolean
    return_field :village, Type::Village.definition

    resolve lambda { |object, inputs, ctx|
      village = Village.find(id: inputs['id'])
      village.disable_recruit = inputs['disabled']
      village.save
      {
        village: village
      }
    }
  end
end
