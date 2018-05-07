# frozen_string_literal: true

require 'test_helper'

class NumericBoundTest < ActiveSupport::TestCase
  test 'lbound works' do
    assert_equal 0, -3.lbound(0)
    assert_equal 0, 0.lbound(0)
    assert_equal 10, 10.lbound(0)
  end

  test 'ubound works' do
    assert_equal 10, 30.ubound(10)
    assert_equal 10, 10.ubound(10)
    assert_equal 5, 5.ubound(10)
  end

  test 'bound works' do
    assert_equal 5, 1.bound(5, 10)
    assert_equal 5, 5.bound(5, 10)
    assert_equal 7, 7.bound(5, 10)
    assert_equal 10, 10.bound(5, 10)
    assert_equal 10, 50.bound(5, 10)
  end
end
