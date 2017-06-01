require 'test_helper'

class ValidatorTest < ActiveSupport::TestCase
  class ValidatorTester
    include Virtus.model(strict: true)
    include RLetters::VirtusExt::Validator

    attribute :string, String

    def validate!
    end
  end

  test 'validate! is called' do
    flexmock(ValidatorTester).new_instances.should_receive(:validate!)
    ValidatorTester.new(string: 'test')
  end
end
