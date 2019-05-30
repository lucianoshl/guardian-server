# frozen_string_literal: true

class Account
  include Mongoid::Document

  field :username, type: String
  field :password, type: String
  field :world, type: String
  field :main, type: Boolean

  has_one :player

  def self.main
    where(main: true).first
  end
end
