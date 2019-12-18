# frozen_string_literal: true

describe Screen::DailyBonus do
  it 'parse load bonus screen' do
    mock_request_from_id('daily_bonus_with_2_chests')

    screen = Screen::DailyBonus.new
    expect(screen.chests.size).to eq(9)
    expect(screen.closed_chests.size).to eq(2)
    screen.open_chest(screen.closed_chests.first)
  end
end
