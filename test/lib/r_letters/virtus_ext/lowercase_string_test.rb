# frozen_string_literal: true

require 'test_helper'

module RLetters
  module VirtusExt
    class LowercaseStringTest < ActiveSupport::TestCase
      class LowerStringTester
        include Virtus.model(strict: true)
        attribute :string, RLetters::VirtusExt::LowercaseString, required: true
      end

      test 'coerce leaves a lowercase string alone' do
        model = LowerStringTester.new(string: 'asdfghj')

        assert_equal 'asdfghj', model.string
      end

      test 'coerce lowercases a mixed-case string' do
        model = LowerStringTester.new(string: 'ÉstiÜdO')

        assert_equal 'éstiüdo', model.string
      end

      test 'coerce chokes on anything else' do
        assert_raises(ArgumentError) do
          LowerStringTester.new(string: 37)
        end
      end
    end
  end
end
