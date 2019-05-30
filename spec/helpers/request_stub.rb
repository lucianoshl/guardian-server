module RequestStub

  def self.defaults(rspec)
    each do |method, info|
      handler = lambda { |request|
        logger.debug("Stub request: #{request.uri}")
        stub_body_file = "#{File.dirname(__FILE__)}/../stub/requests/#{info['body']}"
        raise Exception, "Stub not found #{stub_body_file}" unless File.exist? stub_body_file

        File.read(stub_body_file)
      }

      stub = rspec.stub_request(method.to_sym, Regexp.new(info['uri']))
      stub.to_return(status: 200, body: handler, headers: build_headers(info['body']))
    end

    WebMock.allow_net_connect!
  end

  def self.build_headers(body_file)
    result = {}
    result['content-type'] = content_types(File.extname(body_file))
    result
  end

  def self.content_types(extension)
    result = {}
    result['.html'] = 'text/html; charset=utf-8'
    result[extension]
  end

  def self.each(&block)
    requests_information = YAML.safe_load(File.read("#{File.dirname(__FILE__)}/../stub/requests.yml"))
    requests_information.map do |method, requests|
      requests.map do |_desc, info|
        block.call(method, info)
      end
    end
  end
end