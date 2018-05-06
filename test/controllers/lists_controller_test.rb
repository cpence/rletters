# frozen_string_literal: true
require 'test_helper'

class ListsControllerTest < ActionDispatch::IntegrationTest
  test 'should get authors' do
    get lists_authors_url

    assert_response :success
    assert_includes @response.body, 'Peter J. Hotez'

    obj = JSON.load(@response.body)
    assert_instance_of Array, obj
    assert_instance_of Hash, obj[0]
    refute_nil obj[0]['val']
  end

  test 'should get authors with a filter' do
    get lists_authors_url(q: 'boel')

    assert_response :success
    assert_includes @response.body, 'Marleen Boelaert'
    refute_includes @response.body, 'Peter J. Hotez'

    obj = JSON.load(@response.body)
    assert_instance_of Array, obj
    assert_instance_of Hash, obj[0]
    refute_nil obj[0]['val']
  end

  test 'should get journals' do
    get lists_journals_url

    assert_response :success
    assert_includes @response.body, 'PLoS Neglected Tropical Diseases'

    obj = JSON.load(@response.body)
    assert_instance_of Array, obj
    assert_instance_of Hash, obj[0]
    refute_nil obj[0]['val']
  end

  test 'should get journals with a filer' do
    get lists_journals_url(q: 'act')

    assert_response :success
    assert_includes @response.body, 'Actually a Novel'
    refute_includes @response.body, 'PLoS Neglected Tropical Diseases'

    obj = JSON.load(@response.body)
    assert_instance_of Array, obj
    assert_instance_of Hash, obj[0]
    refute_nil obj[0]['val']
  end
end
