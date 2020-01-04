# frozen_string_literal: true

class Screen::Place < Screen::Base
  include Logging
  screen :place

  attr_accessor :troops, :form, :commands, :error, :incomings

  def parse(page)
    super
    hash_troops = page.search('.unitsInput').map { |a| [a.attr('name'), a.attr('data-all-count').to_i] }.to_h
    self.troops = Troop.new(hash_troops)
    self.form = page.form
    commands = self.commands = OpenStruct.new(all: parse_commands(page))
    commands.returning = commands.all.select(&:returning)
    commands.leaving = commands.all - commands.returning
    self.error = page.search('.error_box').text.strip
    self.incomings = parse_incomings(page)
  end

  def parse_incomings(page)
    parse_table(page, '#commands_incomings table').map do |tr|
      link = tr.search('a')
      link_href = link.attr('href')
      command = Command::Incoming.new
      command.id = link_href.value.scan(/id=(\d+)/).first.first.to_i
      command.origin_id = link_href.value.scan(/village=(\d+)/).number_part
      command.target = link.text.to_coordinate
      command.arrival = tr.search('td')[1].text.to_datetime
      command
    end
  end

  def parse_commands(page)
    parse_table(page, '#commands_outgoings > table').map do |tr|
      link = tr.search('a')
      link_href = link.attr('href')
      command = Command::My.new
      command.id = link_href.value.scan(/id=(\d+)/).first.first.to_i
      command.origin_id = link_href.value.scan(/village=(\d+)/).number_part
      command.target = link.text.to_coordinate
      command.returning = !tr.search('img[src*=return]').empty? || !tr.search('img[src*=cancel]').empty?
      command.arrival = tr.search('td')[1].text.to_datetime
      command
    end
  end

  def send_attack(target, troops)
    logger.info("Sending #{troops}")
    form.fields.map do |field|
      current = troops[field.name]
      form[field.name] = current.to_s unless current.nil?
    end
    form['x'] = target.x
    form['y'] = target.y
    confirm_page = @client.submit(form, form.buttons.first)
    error = confirm_page.search('.error_box').text.strip
    raise convert_error(error) unless error.blank?

    parse(confirm_page.form.submit)
    target_commands = commands.leaving.select { |a| a.target.eql?(target) }
    binding.pry if target_commands.last.nil?
    result = target_commands.last
    result.troop = troops
    travel_time = result.troop.travel_time(result.origin, result.target)
    result.returning_arrival = result.arrival + travel_time
    result.save_if_not_saved
    result
  end

  def convert_error(message)
    if message.include?('para novatos')
      NewbieProtectionException.new(message)
    elsif message.include?('jogador foi banido')
      BannedPlayerException.new
    elsif message.include?('apenas poderá atacar e ser atacado se a razão')
      VeryWeakPlayerException.new
    elsif message.include?('de ataque precisa do')
      NeedsMinimalPopulationException.new(message)
    elsif message.include?('Alvo não existe')
      RemovedPlayerException.new(message)
    elsif message.include?(' convidou o propriet')
      InvitedPlayerException.new(message)
    else
      Exception.new(message)
    end
  end

  def troops_available
    result = troops.clone
    reserved_troops = village.reload.reserved_troops || Troop.new
    result.each do |unit, _qte|
      result[unit] -= reserved_troops[unit]
      result[unit] = 0 if result[unit].negative?
    end
    result
  end

  def next_leaving_command(village)
    selected = commands.leaving.select do |command|
      command.target.distance(village).zero?
    end
    selected.min_by(&:next_arrival).select { |a| a.next_arrival >= Time.now }
  end

  def self.all_places
    Account.main.player.villages.map do |village|
      get_place(village.id)
    end
    @@places
  end

  def self.get_place(vid)
    @@places ||= {}
    return @@places[vid] unless @@places[vid].nil?

    @@places[vid] = Screen::Place.new(village: vid)
  end
end
