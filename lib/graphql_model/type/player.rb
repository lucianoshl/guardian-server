# frozen_string_literal: true

module Type::Player
  include Type::Base

  config do
    argument :id, types.Int
  end
end
