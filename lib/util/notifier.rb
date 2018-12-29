# frozen_string_literal: true

module Notifier
  include Logging
  @@client = Washbullet::Client.new(ENV['PUSH_BULLET_API'])

  def self.notify(content, title: nil)
    return unless client_configured?
    content = content.strip

    account = Account.main
    sufix = "#{account.username}(#{account.world})"
    title = title.nil? ? sufix : "#{sufix} - #{title}"

    begin
      @@client.push_note(
        receiver:   :device,
        params: {
          title: title,
          body:  content
        }
      )
    rescue StandardError => e
      logger.error('Error sending notification')
      logger.error ([e.message] + e.backtrace).join($INPUT_RECORD_SEPARATOR)
    end
  end


  def notify(content, title: nil)
    Notifier.notify(content, title: title)
  end

  def self.client_configured?
    !ENV['PUSH_BULLET_API'].blank?
  end
end
