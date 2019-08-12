# frozen_string_literal: true

describe Task::DailyBonus do
  it 'Task::DailyBonus.run' do
    stub_page = double('screen')
    stub_page.should_receive(:closed_chests).and_return ([
      OpenStruct.new(id:1,is_locked: false, is_collected: false),
      OpenStruct.new(id:1,is_locked: false, is_collected: false)
    ])
    Screen::DailyBonus.stub(:new).and_return stub_page 
    stub_page.should_receive(:open_chest).with(anything).twice

    Task::DailyBonus.new.run
  end
end
