require 'test_helper'

class RLetters::VirtusExt::ValidatorTest < ActiveSupport::TestCase
  class ValidatorTester
    include Virtus.model(strict: true)
    include RLetters::VirtusExt::Validator

    attribute :string, String

    def validate!
    end
  end

  test 'validate! is called' do
    ValidatorTester.any_instance.expects(:validate!)
    ValidatorTester.new(string: 'test')
  end
end
