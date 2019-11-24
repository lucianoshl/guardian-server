# frozen_string_literal: true

describe Task::RecruitBuildTask do

  subject { Task::RecruitBuildTask.new }

  it 'just run with recruit disabled' do
    allow(Account.main).to receive_message_chain(:player, :villages).and_return [
      village = stub_village('my_001')
    ]

    allow(subject).to receive(:build).and_return(Time.now)
    allow(village).to receive(:disable_recruit).and_return(true)
    allow(village).to receive(:disable_build).and_return(true)
    subject.run
  end

end
