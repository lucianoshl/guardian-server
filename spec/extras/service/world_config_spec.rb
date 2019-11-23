# frozen_string_literal: true

describe Service::WorldConfig do
  subject { Service::WorldConfig }

  it 'world has miliseconds' do
    expect(subject.has_milliseconds?).to eq(true)
  end

  it 'world without miliseconds information' do
    allow(Service::WorldConfig).to receive(:parse_table).and_return([])
    expect { subject.has_milliseconds? }.to raise_error('needs implementation')
  end
end
