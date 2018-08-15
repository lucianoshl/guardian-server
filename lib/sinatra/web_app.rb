# frozen_string_literal: true

require 'sinatra'

class WebApp < Sinatra::Base
  Helpers.constants.map do |item|
    helpers Helpers.const_get(item)
  end

  Routes.constants.map do |item|
    register Routes.const_get(item)
  end

  after do
    before_write_response(response)
  end

  get '/reset' do
    Mongoid.purge!
    Helpers::RequestProxy.client.cookie_jar.clear
    return redirect '/'
  end
end
