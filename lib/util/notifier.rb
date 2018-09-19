# frozen_string_literal: true

module Notifier
  include Logging
  @@client = Washbullet::Client.new(ENV['PUSH_BULLET_API'])

  def notify(content, title: nil)
    return unless client_configured?
    content = content.strip

    account = Account.main
    sufix = "Guardian - #{account.username}(#{account.world})"
    title += '-' + sufix unless title.nil?

    begin
      @client.push_note(
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

  def client_configured?
    !ENV['PUSH_BULLET_API'].blank?
  end
end
