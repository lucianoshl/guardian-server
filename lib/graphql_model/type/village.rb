# frozen_string_literal: true

module Type::Village
  include Type::Base

  config do
    argument :id, types.Int
  end
end
