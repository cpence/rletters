# frozen_string_literal: true

require 'test_helper'

module Admin
  class CategoriesControllerTest < ActionDispatch::IntegrationTest
    test 'should get index' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get categories_url

      assert_response :success
    end

    test 'should not get index if not logged in' do
      get categories_url

      assert_redirected_to admin_login_url
    end

    test 'should reorder by posting order' do
      cat1 = create(:category)
      cat2 = create(:category)
      cat3 = create(:category)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])

      # This order parameter will be constructed as JSON, but then deserialized
      # by the Rack middleware automatically; pass the array we really want in
      # this test.
      order = [{ 'id': cat1.id }, { 'id': cat3.id,
                                    'children': [{ 'id': cat2.id }] }]
      post order_categories_url, params: { order: order }, as: :json

      assert_response 204

      assert cat1.reload.childless?
      assert cat2.reload.childless?
      assert cat3.reload.children?

      assert_equal cat3, cat2.parent
      assert_equal [cat2], cat3.children
    end

    test 'should not be able to post order if not logged in' do
      post order_categories_url(order: '[{ id: 1 }]')

      assert_redirected_to admin_login_url
    end

    test 'should show details of category' do
      cat = create(:category)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get category_url(cat)

      assert_response :success
    end

    test 'should not be able to show invalid id' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get category_url(id: '9999')

      assert_response 404
    end

    test 'should not be able to show if not logged in' do
      cat = create(:category)
      get category_url(cat)

      assert_redirected_to admin_login_url
    end

    test 'should get new form' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get new_category_url

      assert_response :success
    end

    test 'should not be able to get new form if not logged in' do
      get new_category_url

      assert_redirected_to admin_login_url
    end

    test 'should create if params are valid' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      post categories_url, params: { documents_category: { name: 'New Category', journals: ['Actually A Novel'] } }

      assert_redirected_to categories_url

      assert Documents::Category.exists?(name: 'New Category')
    end

    test 'should not create if params are invalid' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      post categories_url, params: { documents_category: { journals: ['Actually A Novel'] } }

      assert_redirected_to categories_url
      assert flash[:alert]

      assert Documents::Category.all.empty?
    end

    test 'should not create if not logged in' do
      post categories_url, params: { documents_category: { name: 'New Category', journals: ['Actually A Novel'] } }

      assert_redirected_to admin_login_url

      assert Documents::Category.all.empty?
    end

    test 'should get edit form' do
      cat = create(:category)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get edit_category_url(cat)

      assert_response :success
    end

    test 'should not get edit form for invalid id' do
      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      get edit_category_url(id: '9999')

      assert_response 404
    end

    test 'should not get edit form if not logged in' do
      cat = create(:category)

      get edit_category_url(cat)

      assert_redirected_to admin_login_url
    end

    test 'should patch update' do
      cat = create(:category)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      patch category_url(cat), params: { documents_category: { name: 'new name' } }

      assert_redirected_to categories_url
      assert_equal 'new name', cat.reload.name
    end

    test 'should not patch update for invalid id' do
      cat = create(:category)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      patch category_url(id: '9999'), params: { documents_category: { name: 'new name' } }

      assert_response 404
      assert_equal 'Test Category', cat.reload.name
    end

    test 'should not patch update if not logged in' do
      cat = create(:category)

      patch category_url(cat), params: { documents_category: { name: 'new name' } }

      assert_redirected_to admin_login_url
      assert_equal 'Test Category', cat.reload.name
    end

    test 'should delete destroy' do
      cat = create(:category)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      delete category_url(cat)

      assert_redirected_to categories_url
      assert Documents::Category.count.zero?
    end

    test 'should not delete destroy for invalid id' do
      create(:category)

      post admin_login_url(password: ENV['ADMIN_PASSWORD'])
      delete category_url(id: '9999')

      assert_response 404
      assert_equal 1, Documents::Category.count
    end

    test 'should not delete destroy if not logged in' do
      cat = create(:category)

      delete category_url(cat)

      assert_redirected_to admin_login_url
      assert_equal 1, Documents::Category.count
    end
  end
end
