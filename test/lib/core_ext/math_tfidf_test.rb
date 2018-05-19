# frozen_string_literal: true

require 'test_helper'

class MathTFIDFTest < ActiveSupport::TestCase
  test 'it works with bad values' do
    assert_equal 0, Math.tfidf(nil, nil, nil)
  end

  test 'it works' do
    assert_equal 300, Math.tfidf(100, 10, 10_000)
  end
end
