# frozen_string_literal: true

require_rel './cookie.rb'

class Session
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :ip, type: String

  embeds_many :cookies, class_name: Cookie.to_s
  belongs_to :account

  def self.create(account, cookies)
    session = Session.new
    session.account = account 
    session.cookies = cookies.map { |raw| Cookie.new(JSON.parse(raw.to_json)) }
    session.save
    session
  end

  def self.current(account)
    last_session = Session.where(account: account).desc(:created_at).first
    binding.pry if last_session.nil? && Session.count > 0
    last_session.nil? ? Session.new : last_session
  end
end
