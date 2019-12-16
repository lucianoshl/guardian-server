# frozen_string_literal: true

class Client::Desktop < Client::Base
  def post(uri, query = {}, headers = {})
    super(inject_global(uri), query, headers)
  end

  def get(uri, parameters = [], referer = nil, headers = {})
    super(inject_global(uri), parameters, referer, headers)
  end

  def inject_global(uri)
    uri = inject_base(uri) unless uri.include?('http')
    uri
  end

  def inject_base(uri)
    "https://#{Account.main.world}.tribalwars.com.br#{uri}"
  end

  def login
    Selenium::WebDriver::Chrome::Service.driver_path = '/usr/bin/chromedriver' if Rails.env.production?

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--window-size=1200x600')
    driver = Selenium::WebDriver.for :chrome, options: options
    browser = Watir::Browser.new(driver)
    browser.cookies.clear
    browser.goto('https://www.tribalwars.com.br')
    account = Account.main
    browser.text_field(id: 'user').set account.username
    browser.text_field(id: 'password').set account.password
    browser.link(class: 'btn-login').click
    browser.link(class: 'world-select').wait_until(&:present?)
    target_world = browser.links(class: 'world-select').select do |world|
      world.attribute_value('href').include?(account.world)
    end

    target_world.first.span.click
    # browser.link(class: 'menu-item').wait_until_present
    Session.create(account, browser.cookies.to_a, 'desktop')
    browser.close
  end
end
