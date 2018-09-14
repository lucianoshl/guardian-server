# frozen_string_literal: true

module Type::Account
  include Type::Base

  criteria do |base|
    base.without(:password)
  end
end
