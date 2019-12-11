# frozen_string_literal: true

describe Task::BuildInstantTask do
  subject { Task::BuildInstantTask.new }

  it 'test instant build' do
    main_screen = double(:main)
    allow(Screen::Main).to receive(:new).and_return main_screen
    allow(main_screen).to receive(:build_instant).and_return nil
    allow(main_screen).to receive(:reload).and_return nil

    allow(subject).to receive_message_chain(:village, :id).and_return(1)
    allow(subject).to receive(:build).and_return nil

    subject.run
    # expect(main_screen).to receive(:build_instant)
    # expect(subject).to receive(:build)
  end
end
