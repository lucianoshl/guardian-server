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

  # get '/overlay' do
  #   page = Client::Logged.desktop.get("/game.php?#{params.to_query}", nil, nil)
  #   return fix_html(page)
  # end

  # def fix_html(page)
  #   raw = page.body
  #   raw = raw.gsub(/game\.php/, 'overlay')
  #   raw
  # end

  # def extract_headers
  #   # http_headers = request.env.select{|k,v| k.start_with?('HTTP_')}
  #   http_headers = {}
  #   http_headers.delete('HTTP_HOST')
  #   http_headers.delete('HTTP_ORIGIN')
  #   http_headers.delete('HTTP_REFERER')
  #   http_headers.delete('HTTP_COOKIE')
  #   http_headers.delete('HTTP_USER_AGENT')
  #   http_headers['CONTENT_TYPE'] = request.env['CONTENT_TYPE']
  #   http_headers['CONTENT_LENGTH'] = request.env['CONTENT_LENGTH']
  #   pp http_headers.map { |k, v| [k.gsub(/HTTP_/, '').tr('_', '-').downcase.camelize, v] }.to_h
  #   http_headers.map { |k, v| [k.gsub(/HTTP_/, '').tr('_', '-').downcase.camelize, v] }.to_h
  # end

  # post '/overlay' do
  #   body = request.body.read
  #   page = Client::Logged.desktop.post("/game.php?#{params.to_query}", body, extract_headers)
  #   response.headers.merge!(page.header)
  #   return fix_html(page)
  # end

  get '/reset' do
    Mongoid.purge!
    Helpers::RequestProxy.client.cookie_jar.clear
    return redirect '/'
  end

  # get '/' do
  #   @main_account = Account.main
  #   return Mechanize.new.get('https://www.tribalwars.com.br/').body if @main_account.nil?
  #   return erb :worlds, layout: :base if @main_account.world.nil?
  #   return erb :home, layout: :base
  # end

  # post '/' do
  #   @main_account = Account.main
  #   if @main_account.nil?
  #     account = Account.new params['account']
  #     account.login
  #     account.main = true
  #     account.save
  #     return redirect '/'
  #   end

  #   if @main_account.world.nil?
  #     @main_account.world = params['world']
  #     Event::FirstLogin.new
  #     @main_account.save
  #     return redirect '/'
  #   end
  # end

  # post '/graphql' do
  #   params = JSON.parse request.body.read
  #   result = GuardianSchema.execute(
  #     params['query'],
  #     variables: params['variables'],
  #     context: { current_user: nil }
  #   )
  #   json result
  # end

  # get '/graphiql' do
  #   Rack::GraphiQL.new(endpoint: '/graphql').call(request.env)
  # end

  # get '/healthcheck' do
  # end
end
