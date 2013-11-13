# -*- encoding : utf-8 -*-
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--web-security=no']
      # Uncomment this to enable the 'page.driver.debug' method, which will
      # send you out to Chrome staring at the current DOM state
      #                                  inspector: true,
      #                                  debug: true
    )
end

# Increase the default wait, which is a bit fast for Poltergeist
Capybara.default_wait_time = 8

# Enable Poltergeist
Capybara.javascript_driver = :poltergeist

# Debugging support; render out to a .png in the tmp directory
def render_page(name)
  png_name = name.strip.gsub(/\W+/, '-')
  path = Rails.root.join('tmp', "#{png_name}.png")
  page.driver.render(path)
end

# Uncomment this and you'll get the Rails log messages from your Rails app
# bubbling to the console in Cucumber
# come here mr. ducky, i just want to punch you
# module Capybara
#   class << self
#     def logger_target
#       @logger_target ||= StringIO.new
#     end

#     attr_writer :backtrace_clean_patterns

#     def backtrace_clean_patterns
#       @backtrace_clean_patterns ||= [ %r{/gems/}, %r{/ruby/1} ]
#     end
#   end
# end

# Rails.logger = Logger.new(Capybara.logger_target)

# Capybara.server do |app, port|
#   require 'rack/handler/webrick'

#   logger = Logger.new(Capybara.logger_target)
#   logger.level = Logger::WARN

#   responder = lambda { |request, response|
#     # ...and who's your friend over there, mr. ducky? maybe the want a punch, too.
#     class << response
#       def set_error(ex, backtrace = false)
#         bt = ex.backtrace.reject { |line| Capybara.backtrace_clean_patterns.any? { |pattern| line[pattern] } }

#         Capybara.logger_target << bt.collect { |line| "  #{line}\n" }.join
#         Capybara.logger_target << "\n"
#       end
#     end
#   }

#   Rack::Handler::WEBrick.run(app, :Port => port, :AccessLog => [], :Logger => logger, :RequestCallback => responder)
# end

# Before do
#   Capybara.logger_target.rewind
#   Capybara.logger_target.truncate(0)
# end

# AfterStep do
#   Capybara.logger_target.rewind

#   data = Capybara.logger_target.read
#   $stderr.puts data if !data.empty?

#   Capybara.logger_target.truncate(0)
# end
