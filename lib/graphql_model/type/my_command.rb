# frozen_string_literal: true

module Type::MyCommand
  include Type::Base
  class_base Command::My

  config do
    argument :id, types.Int
    argument :origin_id, types.Int
  end

end
