# frozen_string_literal: true

describe Screen::Statue::Main do
  subject { Screen::Statue::Main.new }
  
  it 'do_request' do
    subject
  end
  
  it 'train' do
    fake_page = double('fake_train_page')
    fake_obj = { 'response': { 'knight': { 'activity': { 'finish_time': 1 } } } }
    allow(fake_page).to receive(:body).and_return(fake_obj.to_json)
    allow(Client::Logged).to receive_message_chain(:mobile, :post).and_return(fake_page)
    subject.train('01','01')
  end
end
