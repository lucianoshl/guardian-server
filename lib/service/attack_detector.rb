module Service::AttackDetector
  # TODO: this is not thread safe
  @running = false

  def self.run(village)
    return if @running
    @running = true
    place = Screen::Place.new(village: village.id)
    place.incomings.map do |incoming|
      run_for_incoming(incoming)
    end
    @running = true
  end

  def self.run_for_incoming(incoming)
    if Command::Incoming.where(id: incoming.id).empty?
      Screen::InfoCommand.new(id: incoming.id).command.save
    end
  end
end