# frozen_string_literal: true
require 'test_helper'

class RLetters::Solr::ConnectionTest < ActiveSupport::TestCase
  test 'search wraps results in a result object' do
    res = RLetters::Solr::Connection.search(q: '*:*')

    assert_kind_of RLetters::Solr::SearchResult, res
  end

  test 'search_raw returns an empty hash if Solr fails' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout

    assert_equal({}, RLetters::Solr::Connection.search_raw(q: ''))
  end

  test 'search_raw converts snake_case Symbols to camelCase Strings' do
    header = RLetters::Solr::Connection.search_raw(def_type: 'lucene')['responseHeader']
    assert_equal 'lucene', header['params']['defType']
  end

  test 'info connects to the right Solr path' do
    RSolr::Client.any_instance.expects(:get).with('admin/system')
    RLetters::Solr::Connection.info
  end

  test 'info returns an empty hash when Solr fails' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    assert_equal({}, RLetters::Solr::Connection.info)
  end

  test 'ping works' do
    assert_kind_of Integer, RLetters::Solr::Connection.ping
  end

  test 'ping returns nil when Solr fails' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout

    assert_nil RLetters::Solr::Connection.ping
  end

  # This is such a vital security requirement that we test it anyway.
  # FIXME: This is probably stupid, but I'm keeping it for the moment.
  test 'Solr schema returns no fulltext for external documents' do
    res = RLetters::Solr::Connection.search_raw(q: 'uid:"gutenberg:3172"',
                                                def_type: 'lucene',
                                                tv: 'true',
                                                fl: '*')

    refute_nil res
    assert_nil res['response']['docs'][0]['fulltext']
    assert_nil res['response']['docs'][0]['fulltext_vectors']
    refute_nil res['response']['docs'][0]['fulltext_url']
  end

  test 'fulltext searches still access external documents' do
    res = RLetters::Solr::Connection.search_raw(q: 'fulltext_search:personage',
                                                def_type: 'lucene',
                                                fl: '*')
    uids = res['response']['docs'].map { |d| d['uid'] }

    assert_includes uids, 'gutenberg:3172'
  end

  test 'fulltext_stem searches still access external documents' do
    # PG3172 contains "violated" and "violates" but not "violate"
    res = RLetters::Solr::Connection.search_raw(q: 'fulltext_stem:violate',
                                                def_type: 'lucene',
                                                fl: '*')
    uids = res['response']['docs'].map { |d| d['uid'] }

    assert_includes uids, 'gutenberg:3172'
  end
end
