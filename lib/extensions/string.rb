# frozen_string_literal: true

class String
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
    begin
      if this.include?('hoje')
        formated = gsub(/hoje ../, Date.today.to_s)
        result = Time.parse(formated)
      elsif this.include?('amanhã')
        tomorrow = Date.today + 1.day
        formated = gsub(/amanhã ../, tomorrow.to_s)
        result = Time.parse(formated)
      elsif this.include?('em')
        date = scan(/em (\d+)\.(\d+)\./).flatten.concat([Time.now.year]).join('/').to_date
        hour = scan(/\d+\:\d+/).flatten.first
        result = Time.parse("#{date} #{hour}")
        raise Exception, 'result < Time.now' if result < Time.now
        result = result
      elsif !scan(/... \d{1,2}, \d{4}/).empty?
        this[0] = this[0].upcase
        raw = this.gsub('Set', 'Sep').gsub('Out', 'Oct').gsub('Dez', 'Dec').gsub('Fev', 'Feb').gsub('Ago', 'Aug')

        has_milliseconds = split(':').size > 3
        miliseconds_format = has_milliseconds ? ':%L' : ''
        result = DateTime.strptime(raw, "%b %d, %Y %H:%M:%S#{miliseconds_format}")
        result = result.to_datetime.change(offset: Time.now.strftime('%z'))

      elsif !scan(/\d+\.\d+\. .. \d+\:\d+/).empty? # ["22.09. às 13:45"]
        date, hour = this.split('. às ')
        date = date.split('.').concat([Time.now.year]).join('/').to_date
        result = Time.zone.parse("#{date} #{hour}")
      else
        raise Exception, 'unsupported parse_datetime date'
      end
    rescue Exception => e
      raise Exception, "Error parsing date \"#{this}\" #{e} #{e.message}"
    end
    result
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
end
