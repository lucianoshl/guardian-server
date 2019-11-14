# frozen_string_literal: true

describe Task::PlayerMonitoringTask do
  subject { Task::PlayerMonitoringTask.new }

  it 'just run twice' do
    point = Coordinate.new(x: 500, y: 500)
    result = Service::Map.find_nearby([point], 50).values
    result.map{|a| a.distance = point.distance(a)}

    point = result.sort_by(&:distance).first
    allow(Account).to receive_message_chain(:main,:player,:villages).and_return([
      Village.new(x: point.x, y: point.y )
    ])
    subject.run
    subject.run
  end

end
