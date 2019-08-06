# frozen_string_literal: true

describe Session do
  it 'convert to desktop cookies' do
    Screen::Main.new # do login
    mobile_client = Client::Logged.mobile
    desktop_client = Client::Logged.desktop

    mobile_client.get('/game.php')
    desktop_client.get('/game.php')

    mobile = mobile_client.cookies
    desktop = desktop_client.cookies

    expect(mobile.size).not_to eq(0)
    expect(desktop.size).not_to eq(0)

    fake_session = Session.new
    fake_session.cookies = mobile.map { |raw| Cookie.new(JSON.parse(raw.to_json)) }
    
    desktop = JSON.parse desktop.to_json
    converted = JSON.parse(fake_session.desktop_session.cookies.map(&:to_raw).to_json)
    
    converted.each_with_index do |cookie1,index|
      cookie2 = desktop[index]
      diff = HashDiff.diff(cookie1,cookie2)
      diff = diff.select{|type,field,diffs| !['accessed_at','created_at'].include?(field) }
      expect(diff.size).to eq(0)
    end


  end
end
