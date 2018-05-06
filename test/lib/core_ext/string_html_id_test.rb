# frozen_string_literal: true
require 'test_helper'

class StringHtmlIdTest < ActiveSupport::TestCase
  test 'html_id sanitizes illegal characters' do
    assert_equal 'a______-_32', 'a$#%/_=-+32'.html_id
  end

  test 'html_id prepends alpha if required' do
    assert_equal 'a1234', '1234'.html_id
  end

  test 'html_id! sanitizes illegal characters' do
    s = +'a$#%/_=-+32'
    s.html_id!

    assert_equal 'a______-_32', s
  end

  test 'html_id! prepends alpha if required' do
    s = +'1234'
    s.html_id!

    assert_equal 'a1234', s
  end
end
