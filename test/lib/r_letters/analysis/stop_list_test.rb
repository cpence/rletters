# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Analysis
    class StopListTest < ActiveSupport::TestCase
      test 'available works' do
        ret = RLetters::Analysis::StopList.available

        assert_kind_of Array, ret
        assert_not ret.empty?
        assert_includes ret, :en
      end

      test 'for works' do
        ret = RLetters::Analysis::StopList.for(:en)

        assert_kind_of Array, ret
        assert_not ret.empty?
        assert_includes ret, 'the'
      end

      test 'for returns nil for missing language' do
        assert_nil RLetters::Analysis::StopList.for(:xx)
      end
    end
  end
end
