# frozen_string_literal: true

require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  test 'should get index' do
    get search_url

    assert_response :success
  end

  test 'should get index with no results' do
    get search_url(q: 'fail')

    assert_response :success
  end

  test 'should get XHR request' do
    get search_url, xhr: true, headers: { 'HTTP_ACCEPT' => 'text/html' }

    assert_response :success
  end

  test 'should get advanced' do
    get search_advanced_url

    assert_response :success
  end
end
