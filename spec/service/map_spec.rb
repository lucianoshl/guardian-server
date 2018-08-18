# frozen_string_literal: true

describe Service::Map do

  it 'load_all_map' do
    distance = 300
    Service::Map.find_nearby([Coordinate.new(x:500,y:500)],distance)
  end

end
