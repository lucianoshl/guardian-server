# frozen_string_literal: true

class Screen::Statue::Main < Screen::Base
  screen :statue

  def parse(page)
    super
  end

  def train(knight, regimen)
    parameters = {
      knight: knight,
      regimen: regimen,
      cheap: 0
    }

    headers = {}
    headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=UTF-8'
    headers['X-Requested-With'] = 'XMLHttpRequest'
    headers['TribalWars-Ajax'] = 1
    headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'

    page = Client::Logged.mobile.post("/game.php?village=#{village.id}&screen=statue&ajaxaction=regimen&h=#{csrf_token}&client_time=#{client_time}", parameters, headers)
    Time.at JSON.parse(page.body)['response']['knight']['activity']['finish_time']
  end
end
