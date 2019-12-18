# frozen_string_literal: true

describe Notifier do
  subject { Class.new { extend Notifier } }

  it 'send_notification' do
    allow(ENV).to receive(:[]).and_return('token')
    subject.notify('hello world')
  end

  it 'send notification with network error' do
    allow(ENV).to receive(:[]).and_return('token')
    allow_any_instance_of(Washbullet::Client).to receive(:push_note).and_raise(StandardError.new)
    subject.notify('hello world')
  end
end
