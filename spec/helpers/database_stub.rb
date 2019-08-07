# frozen_string_literal: true

module DatabaseStub
  def clean_db
    mock_account
    # session = Session.current(Account.main, 'mobile').clone
    # Mongoid.purge!
    # session.account = mock_account
    # raise Exception, "Error saving Session: #{session.errors.to_a}" unless session.save
  end

  def mock_account
    return Account.first if Account.count.positive?

    stub_account = Account.new(main: true)
    stub_account.username = ENV['STUB_USER']
    stub_account.password = ENV['STUB_PASS']
    stub_account.world = ENV['STUB_WORLD']
    stub_account.player = Player.new(points: 1000)
    stub_account.player.ally = Ally.new(id: 'my_ally')
    stub_account.player.ally.save
    stub_account.player.save
    stub_account.save
    stub_account
  end
end
