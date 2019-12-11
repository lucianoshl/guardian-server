# frozen_string_literal: true

describe Session do
  it 'create account' do
    account = double(:account)
    allow(account).to receive(:id).and_return 1
    cookie = Cookie.new
    Session.create(account,[cookie],'mock')
  end
end
