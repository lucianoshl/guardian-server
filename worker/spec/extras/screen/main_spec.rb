# frozen_string_literal: true

describe do
  subject { Screen::Main.new }
  it 'main screen health check' do
    main = subject
    server_time = main.server_time
    current_time = Time.now
    diference = (current_time - server_time).abs
    diference -= 3600 if diference > 3599
    expect(diference).to be < 500

    main.possible_build?(:farm)
  end

  it 'check queue' do
    allow(subject).to receive(:buildings_meta).and_return(
      'main' => { 'level_next' => 12, 'level' => '9' },
      'stable' => { 'level_next' => 10, 'level' => '9' }
    )

    expect(subject.in_queue?(:main)).to eq(true)
    expect(subject.in_queue?(:stable)).to eq(false)
    expect(subject.in_queue?(:wood)).to eq(false)
  end

  # it 'build main' do
  #   allow(subject).to receive(:parse).and_return(nil)
  #   allow(subject).to receive(:buildings_meta).and_return({
  #     'main' =>{'build_link'=> 'fake_request'}
  #   })
  #   subject.build(:main)
  # end
end
