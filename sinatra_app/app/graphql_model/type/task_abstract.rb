# frozen_string_literal: true

module Type::TaskAbstract
  include Type::Base
  class_base Task::Abstract

  mutation do
    name 'RunTaskNow'
    argument :id, !types.String
    type Type::Village.definition
    def call(_object, inputs, _ctx)
      task = Task::Abstract.find(id: inputs['id'])
      task.run_now
      task
    end
  end
end
