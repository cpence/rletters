# frozen_string_literal: true

require 'test_helper'

module RLetters
  module VirtusExt
    class SplitListTest < ActiveSupport::TestCase
      class SplitTester
        include Virtus.model(strict: true)
        attribute :list, RLetters::VirtusExt::SplitList, required: true
      end

      test 'coerce passes along an array' do
        model = SplitTester.new(list: [1, 2, 3])

        assert_equal [1, 2, 3], model.list
      end

      test 'coerce passes through a Documents::StopList' do
        stop_list = build(:stop_list)
        model = SplitTester.new(list: stop_list)

        assert_equal %w[a an the], model.list.sort
      end

      test 'coerce loads a string to a space-separated list' do
        model = SplitTester.new(list: 'a an the')

        assert_equal %w[a an the], model.list.sort
      end

      test 'coerce chokes on anything else' do
        assert_raises(ArgumentError) do
          SplitTester.new(list: 37)
        end
      end
    end
  end
end
