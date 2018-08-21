# frozen_string_literal: true

class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String
  field :password, type: String
  field :world, type: String
  field :main, type: Boolean

  has_one :player

  def self.main
    where(main: true).first
  end

  def self.stub_account
    Account.stub(:main) do
      Account.new(
        username: ENV['STUB_USER'],
        password: ENV['STUB_PASS'],
        world: ENV['STUB_WORLD']
      )
    end
  end
end
