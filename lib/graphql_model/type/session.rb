# frozen_string_literal: true

module Type::Session
  include Type::Base

  config do
    argument :type, types.String
  end

  criteria do |base, args|
    type = args['type'] || 'mobile'
    Client::Logged.send(type).get('/game.php')

    criteria = base.where((args.to_h.map do |k, v|
      field, operation = k.split('_')
      operation.nil? ? [field.to_sym, v] : [field.to_sym.send(operation), v]
    end).to_h)

    criteria.desc(:created_at)
  end
end
