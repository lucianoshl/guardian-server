# frozen_string_literal: true

require_rel './cookie.rb'

class Session
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :ip, type: String
  field :type, type: String

  embeds_many :cookies, class_name: Cookie.to_s
  belongs_to :account

  def self.create(account, cookies, type)
    session = Session.new
    session.account = account
    session.type = type
    session.cookies = cookies.map { |raw| Cookie.new(JSON.parse(raw.to_json)) }
    session.save
    session
  end

  def self.current(account, type)
    last_session = Session.where(account: account, type: type).desc(:created_at).first
    last_session.nil? ? Session.new : last_session
  end

  # def desktop_session
  #   result = Marshal.load(Marshal.dump(self))


  #   result
  # end


end
