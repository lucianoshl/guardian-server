# frozen_string_literal: true

describe Task::TrainKnight do

  it 'TrainKnight.run' do
    # Screen::Statue::Overview.any_instance.stub(:knights_data).and_return({})
    Task::TrainKnight.new.run
  end
end
