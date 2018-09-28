# frozen_string_literal: true

module Type::MyCommand
  include Type::Base
  class_base Command::My

  config do
    argument :id_in, types[types.Int]
  end

  criteria do |base, args|
    base.where((args.to_h.map do |k, v|
      field, operation = k.split('_')
      [field.to_sym.send(operation), v]
    end).to_h)
  end
end
