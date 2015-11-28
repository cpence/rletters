require 'rails_helper'

RSpec.describe RLetters::VirtusExt::ParameterHash do
  class ValidatorTester
    include Virtus.model(strict: true)
    include RLetters::VirtusExt::Validator

    attribute :string, String

    def validate!
    end
  end

  describe '#validate!' do
    it 'is called' do
      expect_any_instance_of(ValidatorTester).to receive(:validate!)
      ValidatorTester.new(string: 'test')
    end
  end
end
