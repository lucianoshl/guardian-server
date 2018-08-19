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
    this = self.gsub(/ +/,' ')
    begin
      if this.include?('hoje')
          formated = gsub(/hoje ../, Date.today.to_s)
          result = Time.parse(formated)
      elsif this.include?('amanhã') then
          tomorrow = Date.today + 1.day
          formated = gsub(/amanhã ../, tomorrow.to_s)
          result =    Time.parse(formated)
      elsif this.include?('em') then
          date = scan(/em (\d+)\.(\d+)\./).flatten.concat([Time.now.year]).join('/').to_date
          hour = scan(/\d+\:\d+/).flatten.first
          result = Time.parse("#{date} #{hour}")
          raise Exception.new("result < Time.now") if result < Time.now
          result =    result
      elsif scan(/... \d{1,2}, \d{4}/).size > 0 then
          raw = this.gsub('Set','Sep').gsub('Out','Oct').gsub('Dez','Dec').gsub('Fev','Feb').gsub('Ago','Aug')
          # TODO: verify if world has miliseconds
          result = DateTime.strptime(raw,"%b %d, %Y %H:%M:%S:%L")
          result = result.to_datetime.change(offset: Time.now.strftime("%z"))

      elsif scan(/\d+\.\d+\. .. \d+\:\d+/).size > 0 then  # ["22.09. às 13:45"]
          date,hour = this.split('. às ')
          date = date.split('.').concat([Time.now.year]).join('/').to_date
          result = Time.zone.parse("#{date} #{hour}")
      else
          raise Exception.new("unsupported parse_datetime date") 
      end
    rescue Exception => e
      raise Exception.new("Error parsing date #{this} #{e} #{e.message}")
    end
    result
  end
end
