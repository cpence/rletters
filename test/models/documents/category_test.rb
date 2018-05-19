# frozen_string_literal: true

require 'test_helper'

module Documents
  class CategoryTest < ActiveSupport::TestCase
    test 'to_s should work' do
      cat = build(:category)

      assert_includes cat.to_s, cat.name
    end

    test 'active should return categories when active' do
      cat = create(:category)
      params = ActionController::Parameters.new(categories: [cat.to_param])

      assert_includes Documents::Category.active(params), cat
    end

    test 'active should return nothing when inactive' do
      params = ActionController::Parameters.new

      assert_empty Documents::Category.active(params)
    end

    test 'should return enabled when enabled' do
      cat = create(:category)

      assert cat.enabled?(categories: [cat.to_param])
    end

    test 'should return disabled when disabled' do
      cat = create(:category)

      refute cat.enabled?({})
    end

    test 'should return toggled params when enabled' do
      cat = create(:category)
      params = ActionController::Parameters.new(categories: [cat.to_param])
      params = cat.toggle_search_params(params)

      assert_nil params[:categories]
    end

    test 'should return toggled params when disabled' do
      cat = create(:category)
      params = cat.toggle_search_params(ActionController::Parameters.new)

      assert_equal [cat.to_param], params[:categories]
    end
  end
end
