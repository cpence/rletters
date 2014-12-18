# -*- encoding : utf-8 -*-

# Generator configuration
Rails.application.config.generators do |generator|
  generator.orm :active_record
  generator.template_engine :haml
  generator.test_framework :rspec,
                           view_specs: false,
                           routing_specs: false
  generator.fixture_replacement :factory_girl,
                                dir: 'spec/factories'
end
