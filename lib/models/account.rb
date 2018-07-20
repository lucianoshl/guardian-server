# frozen_string_literal: true

class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :username, type: String
  field :password, type: String
  field :world, type: String
  field :main, type: Boolean

  def login
    parameters = [username, password, '2.7.8']
    result = Client::Mobile.logged.post('https://www.tribalwars.com.br/m/m/login', parameters)
    Property.put('cookies', Client::Mobile.logged.cookies)
    result = JSON.parse(result.body)
    throw Exception.new(result['error']) unless result['error'].nil?
    result
  end

  def worlds
    login['result']['worlds'].values.flatten.uniq { |a| a['server_name'] }
  end

  def world_login
    client = Client::Mobile.logged
    token = login['result']['token']
    client.post('https://www.tribalwars.com.br/m/m/worlds', [token])
    result = client.post("https://#{world}.tribalwars.com.br/m/g/login", [token, 2, 'android'])
    client.add_global_arg('sid', JSON.parse(result.body)['result']['sid'])
    client.get("https://#{world}.tribalwars.com.br/login.php?mobile&2")
    Property.put('cookies', Client::Mobile.logged.cookies)
  end

  def self.main
    where(main: true).first
  end
end
