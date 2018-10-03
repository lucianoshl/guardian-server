# frozen_string_literal: true

module Type::Property
  include Type::Base

  config do
    argument :id, types.Int
  end
end
