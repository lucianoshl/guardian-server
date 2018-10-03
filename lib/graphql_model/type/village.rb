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

    def call(_object, inputs, _ctx)
      village = Village.find(id: inputs['id'])
      village.disable_recruit = inputs['disabled']
      village.save
      village
    end
  end

  mutation do
    name 'ResetVillage'
    argument :id, !types.Int
    type Type::Village.definition

    def call(_object, inputs, _ctx)
      Village.find(id: inputs['id']).reset
    end
  end

  mutation do
    name 'UpdateBuildModel'
    argument :id, !types.Int
    argument :input, types[Type::Buildings.input_type]
    type Type::Village.definition

    def call(_object, inputs, _ctx)
      binding.pry
    end
  end
end
