# frozen_string_literal: true

# Coverage setup
require 'simplecov'

if ENV['TRAVIS'] || ENV['COVERAGE']
  SimpleCov.start do
    add_filter '/test/'
    add_filter '/config/'
    add_filter '/db/'
    add_filter '/lib/tasks/'
    add_filter '/vendor/bundle/'
    add_filter '.haml'
    add_filter '.erb'
    add_filter '.builder'

    add_group 'Controllers', 'app/controllers'
    add_group 'Helpers', 'app/helpers'
    add_group 'Jobs', 'app/jobs'
    add_group 'Mailers', 'app/mailers'
    add_group 'Models', 'app/models'
    add_group 'Core Extensions', 'lib/core_ext'
    add_group 'Library', 'lib/r_letters'
  end

  SimpleCov.merge_timeout 3600

  # We'll override this in the system tests
  SimpleCov.command_name 'test:unit'
end
