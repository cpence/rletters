# frozen_string_literal: true

require 'test_helper'

module Admin
  class SnippetsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @snippet = create(:snippet)
    end

    test 'should get index' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get snippets_url

      assert_response :success
    end

    test 'should not get index if not logged in' do
      get snippets_url

      assert_redirected_to admin_login_url
    end

    test 'should get new form' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get new_snippet_url

      assert_response :success
    end

    test 'should not be able to get new form if not logged in' do
      get new_snippet_url

      assert_redirected_to admin_login_url
    end

    test 'should not create for a novel name' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      post snippets_url, params: { admin_snippet: { name: 'newname', language: 'vi', content: 'test' } }

      assert_response 404
    end

    test 'should create if params are valid' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      post snippets_url, params: { admin_snippet: { name: @snippet.name, language: 'vi', content: 'test' } }

      assert_redirected_to snippets_url

      assert Admin::Snippet.exists?(name: @snippet.name, language: 'vi')
    end

    test 'should not create if params are invalid' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      post snippets_url, params: { admin_snippet: { name: @snippet.name, content: 'only content' } }

      assert_redirected_to snippets_url
      assert flash[:alert]

      assert_equal 1, Admin::Snippet.count
    end

    test 'should not create if not logged in' do
      post snippets_url, params: { admin_snippet: { name: @snippet.name, language: 'vi', content: 'test' } }

      assert_redirected_to admin_login_url

      assert_equal 1, Admin::Snippet.count
    end

    test 'should get edit form' do
      snippet = Admin::Snippet.find_by!(name: @snippet.name)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get edit_snippet_url(snippet)

      assert_response :success
    end

    test 'should not get edit form for invalid id' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get edit_snippet_url(id: '9999')

      assert_response 404
    end

    test 'should not get edit form if not logged in' do
      snippet = Admin::Snippet.find_by!(name: @snippet.name)

      get edit_snippet_url(snippet)

      assert_redirected_to admin_login_url
    end

    test 'should patch update' do
      snippet = Admin::Snippet.find_by!(name: @snippet.name)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      patch snippet_url(snippet), params: { admin_snippet: { content: 'test' } }

      assert_redirected_to snippets_url
      assert_equal 'test', snippet.reload.content
    end

    test 'should not patch update for invalid id' do
      Admin::Snippet.find_by!(name: @snippet.name)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      patch snippet_url(id: '9999'), params: { admin_snippet: { content: 'test' } }

      assert_response 404
    end

    test 'should not patch update if not logged in' do
      snippet = Admin::Snippet.find_by!(name: @snippet.name)

      patch snippet_url(snippet), params: { admin_snippet: { content: 'test' } }

      assert_redirected_to admin_login_url
      assert_not_equal 'test', snippet.reload.content
    end

    test 'should not be able to delete English snippets' do
      snippet = Admin::Snippet.find_by!(name: @snippet.name, language: 'en')

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      delete snippet_url(snippet)

      assert_response 400
      assert_equal 1, Admin::Snippet.count
    end

    test 'should delete destroy for non-English' do
      snippet = create(:snippet, language: 'vi')

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      delete snippet_url(snippet)

      assert_redirected_to snippets_url
      assert_equal 1, Admin::Snippet.count
    end

    test 'should not delete destroy for invalid id' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      delete snippet_url(id: '9999')

      assert_response 404
      assert_equal 1, Admin::Snippet.count
    end

    test 'should not delete destroy if not logged in' do
      delete snippet_url(@snippet)

      assert_redirected_to admin_login_url
      assert_equal 1, Admin::Snippet.count
    end
  end
end
