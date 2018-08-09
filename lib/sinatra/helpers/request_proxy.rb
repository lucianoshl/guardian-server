# frozen_string_literal: true

module Helpers::RequestProxy
  @@client = Mechanize.new

  def self.client
    @@client
  end

  def proxy_request(base = nil)
    headers = generate_headers
    method = request.env['REQUEST_METHOD'].downcase.to_sym

    client = @@client

    uri = base + request.env['PATH_INFO']
    if method.eql? :get
      result = client.get(uri, nil, nil, headers)
    else
      result = client.post(uri, params.to_query, headers)
    end

    if result.code == "302"
      redirect_uri = URI.parse(result.header['location'])
      redirect redirect_uri.to_s.split(redirect_uri.host).last
      return ''
    end

    return result.body
  end

  def fix_header_value(value)
    value.gsub(/domain=(.+?),/,"domain=#{request.host}")
  end

  def generate_headers
    allowed_headers = /HTTP_.+|CONTENT_.+/
    ignored_haders = /HTTP_HOST|HTTP_ORIGIN|HTTP_COOKIE|HTTP_REFERER/
    http_headers = request.env.select do |k, _v|
      allowed = !k.match(allowed_headers).nil?
      ignored = !k.match(ignored_haders).nil?
      allowed && !ignored
    end
    http_headers.map { |k, v| [k.gsub(/HTTP_/, '').tr('_', '-').downcase.camelize, v] }.to_h
  end
end
