# frozen_string_literal: true
require 'test_helper'

class IntegerFactorialTest < ActiveSupport::TestCase
  test 'factorial works' do
    assert_equal 24, 4.factorial
    assert_equal 3_628_800, 10.factorial

    assert_equal 1, 0.factorial
    assert_equal 1, 1.factorial
    assert_equal 2, 2.factorial
  end
end
