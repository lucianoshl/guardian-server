# frozen_string_literal: true

describe Screen::Smith do
  subject { Screen::Smith.new }
  it 'do_request' do
    researched = subject.researched_units
    expect(researched.spear).to eq(1)
    expect(researched.sword).to eq(1)
    expect(researched.axe).to eq(0)
    expect(researched.archer).to eq(0)
    expect(researched.spy).to eq(0)
    expect(researched.light).to eq(0)
    expect(researched.marcher).to eq(0)
    expect(researched.heavy).to eq(0)
    expect(researched.ram).to eq(0)
    expect(researched.catapult).to eq(0)
    expect(researched.knight).to eq(0)
    expect(researched.snob).to eq(0)
  end

  it 'check_spy_is_researched' do
    expect(subject.spy_is_researched?).to eq(false)
  end
end
