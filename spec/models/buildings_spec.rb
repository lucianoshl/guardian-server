# frozen_string_literal: true

describe Buildings do
  it 'buildings -' do
    a = Buildings.new(main: 5, wood: 4)
    b = Buildings.new(main: 4, wood: 3)
    c = a - b
    expect(c.main).to eq(1)
    expect(c.wood).to eq(1)
    expect(c.stone).to eq(0)
  end


  it 'buildings contains' do
    a = Buildings.new(main: 5, wood: 4)
    b = Buildings.new(main: 4, wood: 3)

    expect(a.contains?(b)).to eq(true)
    expect(b.contains?(a)).to eq(false)
    expect(b.contains?(b)).to eq(true)
    expect(a.contains?(a)).to eq(true)
  end

  it 'buildings has negative' do
    a = Buildings.new(main: 5, wood: 4)
    b = Buildings.new(main: 4, wood: 3)
    not_has_negative = a - b
    has_negative = b - a

    expect(not_has_negative.has_negative?).to eq(false)
    expect(has_negative.has_negative?).to eq(true)
  end

  it 'inspect' do
    a = Buildings.new(main: 5, wood: 4)
    expect(a.inspect).to eq('Buildings[main:5 wood:4]')
  end
end
