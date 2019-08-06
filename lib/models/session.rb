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
    last_session.nil? ? Session.new : last_session
  end

  def desktop_session
    result = Marshal.load(Marshal.dump(self))
    result.cookies.last['origin'].gsub(/\/\/game\.php.+/,'/game.php')
    global_village_id_1 = result.cookies.select{|a| a['name'] == 'global_village_id'}.first
    global_village_id_2 = global_village_id_1.clone
    result.cookies << global_village_id_2

    global_village_id_1['origin'] = global_village_id_1['origin'].gsub(/\/\/game.php.+/,'/game.php')
    global_village_id_1['path'] = '/'

    global_village_id_2['origin'] = global_village_id_2['origin'].gsub(/\?.+/,'?screen=overview&intro')

    result
  end
end
