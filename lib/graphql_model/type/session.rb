# frozen_string_literal: true

module Type::Session
  include Type::Base

  criteria do |base, args|
    Client::Logged.mobile.get('/game.php')

    criteria = base.where((args.to_h.map do |k, v|
      field, operation = k.split('_')
      [field.to_sym.send(operation), v]
    end).to_h)
    
    criteria.desc(:created_at)
  end

end
