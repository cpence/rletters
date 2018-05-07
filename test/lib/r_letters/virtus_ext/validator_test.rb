# frozen_string_literal: true

require 'test_helper'

module RLetters
  module VirtusExt
    class ValidatorTest < ActiveSupport::TestCase
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
  end
end
