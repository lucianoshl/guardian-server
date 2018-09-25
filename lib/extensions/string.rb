# frozen_string_literal: true

class String
  include R18n::Helpers
  # TODO: change to remote server locale
  R18n.set('pt')
  @@hash_values = nil


  def underscore
    to_s.gsub(/::/, '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .downcase
  end

  def to_datetime
    result = nil
    this = gsub(/ +/, ' ')
    has_milliseconds = split(':').size > 3
    miliseconds_format = has_milliseconds ? ':%L' : ''
    base_format = "%b %d, %Y %H:%M:%S#{miliseconds_format}"

    formated = nil
    if this.include?('hoje')
      formated = gsub(/hoje ../, Date.today.strftime('%b %d, %Y'))
    elsif this.include?('amanhã')
      tomorrow = Date.today + 1.day
      formated = gsub(/amanhã ../, tomorrow.strftime('%b %d, %Y'))
    elsif this.include?('em')
      date = scan(/em (\d+)\.(\d+)\./).flatten.concat([Time.now.year]).join('/').to_date
      hour = split(' ').last
      formated = "#{date.strftime('%b %d, %Y')} #{hour}"
    elsif !scan(/... \d{1,2}, \d{4}/).empty?
      this[0] = this[0].upcase
      original_locale_month = this.split(' ').first
      english_locale_month = month_mapping(original_locale_month)
      formated = this.gsub(original_locale_month, english_locale_month)
    elsif !scan(/\d+\.\d+\. .. \d+\:\d+/).empty? # ["22.09. às 13:45"]
      date = scan(/(\d+)\.(\d+)\./).flatten.concat([Time.now.year]).join('/').to_date
      hour = split(' ').last
      formated = "#{date.strftime('%b %d, %Y')} #{hour}"
    else
      raise Exception, 'unsupported parse_datetime date'
    end

    begin
      parsed = DateTime.strptime(formated.strip, base_format)
    rescue Exception => e
      raise Exception, "Error parsing date \"#{this}\" #{e} #{e.message}"
    end
    parsed.change(offset: Time.now.strftime('%z'))
  end

  def snakecase
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .gsub(/\s/, '_')
      .gsub(/__+/, '_')
      .downcase
  end

  def extract_coordinate
    scan(/\d{3}\|\d{3}/).first.to_coordinate
  end

  def month_mapping(month)
    if @@hash_values.nil?
      @@hash_values = {}
      (0..11).map do |index|
        date = Time.now.beginning_of_year + index.month
        key = l date, '%b'
        key[0] = key[0].upcase
        @@hash_values[key] = date.strftime '%b'
      end
    end
    @@hash_values[month]
  end
end
