# -*- encoding : utf-8 -*-
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app,
                                    inspector: true,
                                    debug: true
    )
end


# Increase the default wait, which is a bit fast for Poltergeist
Capybara.default_wait_time = 8

# Enable Poltergeist
Capybara.javascript_driver = :poltergeist

# Uncomment this to enable the 'page.driver.debug' method, which will
# send you out to Chrome staring at the current DOM state
# Capybara.javascript_driver = :poltergeist_debug

# Debugging support; render out to a .png in the tmp directory
def render_page(name)
  png_name = name.strip.gsub(/\W+/, '-')
  path = Rails.root.join('tmp', "#{png_name}.png")
  page.driver.render(path)
end
