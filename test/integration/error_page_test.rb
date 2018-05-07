# frozen_string_literal: true

require 'test_helper'

class ErrorPageTest < ActionDispatch::IntegrationTest
  test 'should render 404 template' do
    get '/asdf/notapage'

    assert_response 404
    assert_includes @response.body, '<div>'
  end

  test 'should render 500 template' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    get search_url

    assert_response 500
    assert_includes @response.body, '<div>'
  end
end
