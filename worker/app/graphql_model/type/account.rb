# frozen_string_literal: true

module Type::Account
  include Type::Base

  criteria do |base|
    base.without(:password)
  end

  mutation do
    name 'CreateAccount'
    argument :username, !types.String
    argument :password, !types.String
    argument :world, !types.String
    type Type::Account.definition

    def call(_object, inputs, _ctx)
      return Account.main unless Account.main.nil?

      new_account = Account.new(inputs.to_h)
      new_account.main = true
      new_account.save
      Event::FirstLogin.new
      new_account
    end
  end
end
