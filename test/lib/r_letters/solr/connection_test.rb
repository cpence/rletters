# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Solr
    class ConnectionTest < ActiveSupport::TestCase
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
    end
  end
end
