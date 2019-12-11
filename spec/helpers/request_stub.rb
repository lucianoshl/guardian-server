# frozen_string_literal: true

module RequestStub
  def mock_request_from_id(id)
    method, info = find_stub(id)
    mock_request(method, info)
  end

  def get_mock_page(id)
    method, info = find_stub(id)
    html = File.read("#{File.dirname(__FILE__)}/../stub/requests/#{info['body']}")
    Mechanize::Page.new(nil, { 'content-type' => 'text/html' }, html, nil, Mechanize.new)
  end

  def mock_request(method, info)
    stub = WebMock.stub_request(method.to_sym, Regexp.new(info['uri']))
    stub.to_return(status: 200, body: mock_handler(info), headers: build_headers(info['body']))
  end

  def request_mock_defaults
    each(true) do |method, info|
      mock_request method, info
    end

    WebMock.allow_net_connect!
  end

  def mock_handler(info)
    lambda { |_request|
      stub_body_file = "#{File.dirname(__FILE__)}/../stub/requests/#{info['body']}"
      raise Exception, "Stub not found #{stub_body_file}" unless File.exist? stub_body_file

      File.read(stub_body_file)
    }
  end

  def build_headers(body_file)
    result = {}
    result['content-type'] = content_types(File.extname(body_file))
    result
  end

  def content_types(extension)
    result = {}
    result['.html'] = 'text/html; charset=utf-8'
    result[extension]
  end

  def each(only_default = false, &block)
    requests_information = YAML.safe_load(File.read("#{File.dirname(__FILE__)}/../stub/requests.yml"))
    requests_information.map do |method, requests|
      requests.map do |id, info|
        block.call(method, info, id) if !only_default || info['default'] == true
      end
    end
  end

  def find_stub(id)
    each do |method, info, stub_id|
      return [method, info] if stub_id == id
    end
  end
end
