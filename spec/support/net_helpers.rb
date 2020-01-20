module NetHelpers
  def stub_http_request(method, url, status = %w[200 OK], body = nil, _headers = {}, _strict = true)
    stub_request(method, url).to_return(body: body, status: status)
  end
end

RSpec.configure do |config|
  config.include(NetHelpers)
end
