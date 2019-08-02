# frozen_string_literal: true

module Type::Incoming
  include Type::Base
  class_base Command::Incoming

  config do
    argument :id, types.Int
  end

end
