# frozen_string_literal: true

describe Coordinate do

  it '==' do
    coord = Coordinate.new(x: 1, y: 1)
    coord2 = Coordinate.new(x: 1, y: 2)
    expect(coord == coord2).to eq(false)
    expect(coord == coord.clone).to eq(true)
    expect(coord == 1).to eq(false)
  end

  it 'to_s' do
    coord = Coordinate.new(x: 1, y: 1)
    expect(coord.to_s).to eq("1|1")
  end

  it 'to_h' do
    coord = Coordinate.new(x: 1, y: 1)
    coord = coord.to_h
    expect(coord['x']).to eq(1)
    expect(coord['y']).to eq(1)
  end

end
