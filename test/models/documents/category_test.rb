# frozen_string_literal: true
require 'test_helper'

class Documents::CategoryTest < ActiveSupport::TestCase
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
    params = cat.toggle_search_params(ActionController::Parameters.new())

    assert_equal [cat.to_param], params[:categories]
  end
end
