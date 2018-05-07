# frozen_string_literal: true

require 'test_helper'

class SearchApiTest < ActionDispatch::IntegrationTest
  test 'should load a basic search' do
    get search_url(format: 'json', page: '1', per_page: '10')
    json = JSON.parse(@response.body)

    assert_response :success
    assert_equal 'application/json', @response.content_type

    assert_equal 1502, json['results']['num_hits']
    assert_equal 10, json['results']['documents'].size

    assert_equal '*:*', json['results']['solr_params']['q']
    assert_equal 'lucene', json['results']['solr_params']['defType']
    assert_equal '10', json['results']['solr_params']['start']
    assert_equal '10', json['results']['solr_params']['rows']
  end

  test 'should load a faceted search' do
    get search_url(format: 'json', fq: ['authors_facet:"Alan Fenwick"'])
    json = JSON.parse(@response.body)

    assert_response :success
    assert_equal 9, json['results']['num_hits']
    assert_equal 'authors_facet:"Alan Fenwick"', json['results']['solr_params']['fq']
  end

  test 'should load document details' do
    get search_url(format: 'json', advanced: 'true',
                   q: 'doi:"10.1371/journal.pntd.0000534"')
    json = JSON.parse(@response.body)

    assert_response :success
    assert_equal 1, json['results']['num_hits']

    doc = json['results']['documents'][0]
    refute_nil doc
    assert_equal '10.1371/journal.pntd.0000534', doc['doi']
    assert_equal 'Creative Commons Attribution (CC BY)', doc['license']
    assert_equal 11, doc['authors'].size
    assert_equal 'Wenbao Zhang', doc['authors'][0]['full']
    assert_equal 'Zhuangzhi', doc['authors'][1]['first']
    assert_equal 'PLoS Neglected Tropical Diseases', doc['journal']
    assert_equal '3', doc['volume']
  end
end
