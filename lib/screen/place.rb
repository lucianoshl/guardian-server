# frozen_string_literal: true

class Screen::Place < Screen::Base
  include Logging
  screen :place

  attr_accessor :troops, :form, :commands, :error

  def parse(page)
    super
    self.troops = page.search('.unitsInput').map { |a| [a.attr('name'), a.attr('data-all-count').to_i] }.to_h
    self.troops = Troop.new(troops)
    self.form = page.form
    commands = self.commands = OpenStruct.new(all: parse_commands(page))
    commands.returning = commands.all.select(&:returning)
    commands.leaving = commands.all - commands.returning
    self.error = page.search('.error_box').text.strip
  end

  def parse_commands(page)
    parse_table(page, '#commands_outgoings').map do |tr|
      link = tr.search('a')
      link_href = link.attr('href')
      command = Command.new
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
    target_commands.last
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
    else
      Exception.new(message)
    end
  end
end



