
# Coverage setup
if ENV['TRAVIS'] || ENV['COVERAGE']
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/features/'
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/vendor/bundle/'
    add_filter '.haml'
    add_filter '.erb'
    add_filter '.builder'
  end

  SimpleCov.at_exit do
    # We want to disable WebMock before we send results to Code Climate, or
    # it'll block the request
    WebMock.allow_net_connect!

    SimpleCov.result.format!
  end
end
