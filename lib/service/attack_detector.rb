# frozen_string_literal: true

module Service::AttackDetector
  include Notifier

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
      command = Screen::InfoCommand.new(id: incoming.id).Command
      command.save
      notify(%(
Ataque detectado as #{command.create_at.format}
Jogador: #{command.origin.player.name}
Possiveis unidades:
#{command.possible_troop.map { |id| Unit.get(id).name }.map { |a| "\t- #{a}" }.join("\n")}
      ))
    end
  end
end
