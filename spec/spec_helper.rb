# SimpleCov configuration has to be the very first thing we load
require 'simplecov_helper'

RSpec.configure do |config|
  # Switch to the new RSpec syntax
  config.expect_with(:rspec) do |e|
    e.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with(:rspec) do |m|
    m.verify_partial_doubles = true
  end

  # Enable re-running failures automatically
  status_path = 'spec/status.txt'
  config.example_status_persistence_file_path = status_path

  config.order = :random
  Kernel.srand config.seed

  config.disable_monkey_patching!
  config.color = true
  config.tty = true
end
