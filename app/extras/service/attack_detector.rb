# frozen_string_literal: true

module Service::AttackDetector
  extend Notifier

  # TODO: this is not thread safe
  @@running = false

  def self.run
    return if @@running

    @@running = true
    Screen::Place.all_places.values.map(&:incomings).flatten.map do |incoming|
      run_for_incoming(incoming)
    end
    @@running = true
  end

  def self.run_for_incoming(incoming)
    if Command::Incoming.where(id: incoming.id).empty?
      command = Screen::InfoCommand.new(id: incoming.id).command
      notify(%(
Ataque detectado as #{command.create_at.format_date} na aldeia #{command.target}
Jogador: #{command.origin.player.name}
Possiveis unidades:
#{command.possible_troop.map { |id| Unit.get(id).name }.map { |a| "\t- #{a}" }.join("\n")}
      ))
      command.save
    end
  end
end
