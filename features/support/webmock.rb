require 'webmock/cucumber'
WebMock.disable_net_connect!(:allow_localhost => true)

Before do
  stub_request(:any, 'https://www.google.com/jsapi')
end
