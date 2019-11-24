# frozen_string_literal: true

describe Task::TrainKnight do
  before do
    @stub = double(:status_screen)
    allow(Screen::Statue::Overview).to receive(:new).and_return(@stub)
    allow(@stub).to receive(:builded).and_return(true)
  end

  def run_for_status(status)
    allow(@stub).to receive(:knights_data).and_return('11': {
                                                        'activity' => { 'type' => status }
                                                      })
    Task::TrainKnight.new.run
  end

  it 'reviving knight' do
    run_for_status('reviving')
  end

  it 'travel knight' do
    run_for_status('travel')
  end

  it 'dead knight' do
    run_for_status('dead')
  end

  it 'training knight' do
    run_for_status('training')
  end

  it 'home knight' do
    statue_main = double(:status_screen)
    allow(Screen::Statue::Main).to receive(:new).and_return(statue_main)
    allow(statue_main).to receive_message_chain(:resources, :include?).and_return(true)
    allow(statue_main).to receive(:train).and_return(nil)

    allow(@stub).to receive(:knights_data).and_return('11': {
                                                        'activity' => { 'type' => 'home' },
                                                        'home_village' => { 'id' => 1 },
                                                        'usable_regimens' => [{ 'id' => 1, 'res_cost' => { wood: 1, stone: 1, iron: 1 } }]
                                                      })
    Task::TrainKnight.new.run
  end
end
