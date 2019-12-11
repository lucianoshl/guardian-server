# frozen_string_literal: true

describe Report do

  subject { Report.new }

  it 'before_save callback' do
    allow(subject).to receive(:[]).with('_type').and_return 'mock'
    expect { subject.save }.to raise_error(Exception)
  end

  it 'erase win report' do
    allow(subject).to receive(:dot).and_return 'green'
    allow(subject).to receive(:erase_uri).and_return 'fake_request'
    expect(subject.erase?).to eq(true)
    expect(subject.win?).to eq(true)
    subject.erase if subject.erase?
  end

  it 'report with troops' do
    allow(subject).to receive(:def_troops).and_return Troop.new(spear: 5)
    expect(subject.has_troops).to eq(true)
  end

  it 'mark report read' do
    allow(subject).to receive(:save).and_return nil
    expect(subject.read).to eq(false)
    subject.mark_read
    expect(subject.read).to eq(true)
  end

  it 'check ram to destroy wall' do
    allow(subject).to receive(:buildings).and_return Buildings.new(wall: 5)
    expect(subject.rams_to_destroy_wall).to eq(28)
  end

  it 'possible attack' do
    allow(subject).to receive(:dot).and_return 'red'
    expect(subject.possible_attack?).to eq(false)
  end

  it 'missing implementation methods' do
    subject.produced_resource?(100)
    subject.time_to_produce(100)
  end
  

end
