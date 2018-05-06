# frozen_string_literal: true
require 'test_helper'

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test 'should route to #not_found' do
    assert_generates '/404', controller: 'errors', action: 'not_found'
    assert_generates '/404.html', controller: 'errors', action: 'not_found', format: 'html'
  end

  test 'should route to #unprocessable' do
    assert_generates '/422', controller: 'errors', action: 'unprocessable'
    assert_generates '/422.html', controller: 'errors', action: 'unprocessable', format: 'html'
  end

  test 'should route to #internal_error' do
    assert_generates '/500', controller: 'errors', action: 'internal_error'
    assert_generates '/500.html', controller: 'errors', action: 'internal_error', format: 'html'
  end
end
