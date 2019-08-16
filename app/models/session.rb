# frozen_string_literal: true

class Session
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :ip, type: String
  field :type, type: String

  embeds_many :cookies, class_name: Cookie.to_s
  belongs_to :account, optional: Rails.env.test?

  def self.create(account, cookies, type)
    session = Session.new
    session.account_id = account.id
    session.type = type
    session.cookies = cookies.map { |raw| Cookie.new(JSON.parse(raw.to_json)) }
    raise Exception.new("Error saving session: #{session.errors}") unless session.save
    session
  end

  def self.current(account, type)
    last_session = Session.where(account_id: account.id, type: type).desc(:created_at).first
    last_session.nil? ? Session.new : last_session
  end
end
