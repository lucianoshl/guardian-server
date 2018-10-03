# frozen_string_literal: true

module Type::Property
  include Type::Base

  config do
    argument :key, types.String
  end
end
