# frozen_string_literal: true

require 'test_helper'

module Admin
  class StopListsControllerTest < ActionDispatch::IntegrationTest
    SEEDED_STOP_LISTS = 25

    test 'should get index' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get stop_lists_url

      assert_response :success
    end

    test 'should not get index if not logged in' do
      get stop_lists_url

      assert_redirected_to admin_login_url
    end

    test 'should get new form' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get new_stop_list_url

      assert_response :success
    end

    test 'should not be able to get new form if not logged in' do
      get new_stop_list_url

      assert_redirected_to admin_login_url
    end

    test 'should create if params are valid' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      post stop_lists_url, params: { documents_stop_list: { language: 'vi', list: 'test the' } }

      assert_redirected_to stop_lists_url

      assert Documents::StopList.exists?(language: 'vi')
    end

    test 'should not create if params are invalid' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      post stop_lists_url, params: { documents_stop_list: { list: 'just a list' } }

      assert_redirected_to stop_lists_url
      assert flash[:alert]

      assert_equal SEEDED_STOP_LISTS, Documents::StopList.count
    end

    test 'should not create if not logged in' do
      post stop_lists_url, params: { documents_stop_list: { language: 'vi', list: 'test the' } }

      assert_redirected_to admin_login_url

      assert_equal SEEDED_STOP_LISTS, Documents::StopList.count
    end

    test 'should get edit form' do
      list = Documents::StopList.find_by!(language: 'en')

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get edit_stop_list_url(list)

      assert_response :success
    end

    test 'should not get edit form for invalid id' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get edit_stop_list_url(id: '9999')

      assert_response 404
    end

    test 'should not get edit form if not logged in' do
      list = Documents::StopList.find_by!(language: 'en')

      get edit_stop_list_url(list)

      assert_redirected_to admin_login_url
    end

    test 'should patch update' do
      list = Documents::StopList.find_by!(language: 'en')

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      patch stop_list_url(list), params: { documents_stop_list: { language: 'vi' } }

      assert_redirected_to stop_lists_url
      assert_equal 'vi', list.reload.language
    end

    test 'should not patch update for invalid id' do
      list = Documents::StopList.find_by!(language: 'en')

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      patch stop_list_url(id: '9999'), params: { documents_stop_list: { language: 'vi' } }

      assert_response 404
      assert_equal 'en', list.reload.language
    end

    test 'should not patch update if not logged in' do
      list = Documents::StopList.find_by!(language: 'en')

      patch stop_list_url(list), params: { documents_stop_list: { language: 'vi' } }

      assert_redirected_to admin_login_url
      assert_equal 'en', list.reload.language
    end

    test 'should delete destroy' do
      list = Documents::StopList.find_by!(language: 'en')

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      delete stop_list_url(list)

      assert_redirected_to stop_lists_url
      assert_equal SEEDED_STOP_LISTS - 1, Documents::StopList.count
    end

    test 'should not delete destroy for invalid id' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      delete stop_list_url(id: '9999')

      assert_response 404
      assert_equal SEEDED_STOP_LISTS, Documents::StopList.count
    end

    test 'should not delete destroy if not logged in' do
      list = Documents::StopList.find_by!(language: 'en')

      delete stop_list_url(list)

      assert_redirected_to admin_login_url
      assert_equal SEEDED_STOP_LISTS, Documents::StopList.count
    end
  end
end
