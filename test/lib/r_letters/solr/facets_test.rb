# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Solr
    class FacetsTest < ActiveSupport::TestCase
      setup do
        solr_response = build(:solr_response).response
        rsolr = RSolr::Ext::Response::Base.new(solr_response, 'search', nil)

        @facets = RLetters::Solr::Facets.new(rsolr.facets, rsolr.facet_queries)
      end

      test 'search_params works for empty set of facets' do
        p = ActionController::Parameters.new(controller: 'search', action: 'index',
                                             fq: ['authors_facet:"C. Dickens"'])

        out = RLetters::Solr::Facets.search_params(p, [])
        assert_nil out[:fq]
      end

      test 'search_params works for a facet' do
        p = ActionController::Parameters.new(controller: 'search', action: 'index')
        f = @facets.for_field(:authors_facet).find { |o| o.value == 'C. Dickens' }

        out = RLetters::Solr::Facets.search_params(p, [f])
        assert_equal 1, out[:fq].count
        assert_equal 'authors_facet:"C. Dickens"', out[:fq][0]
      end

      test 'active works when empty' do
        p = ActionController::Parameters.new(controller: 'search', action: 'index')

        assert_empty @facets.active(p)
      end

      test 'active works for a facet' do
        p = ActionController::Parameters.new(controller: 'search', action: 'index',
                                             fq: ['authors_facet:"C. Dickens"'])
        f = @facets.for_field(:authors_facet).find { |o| o.value == 'C. Dickens' }

        assert_equal [f], @facets.active(p)
      end

      test 'for_field has the right hash keys' do
        refute_empty @facets.for_field(:authors_facet)
        refute_empty @facets.for_field(:journal_facet)
        refute_empty @facets.for_field(:year)
      end

      test 'for_field parses authors_facet correctly' do
        f = @facets.for_field(:authors_facet).find { |o| o.value == 'C. Dickens' }

        refute_nil f
        assert_equal 1, f.hits
      end

      test 'for_field does not include entries for non-existent authors' do
        f = @facets.for_field(:authors_facet).find { |o| o.value == 'W. Shatner' }

        assert_nil f
      end

      test 'for_field parses journal_facet correctly' do
        f = @facets.for_field(:journal_facet).find { |o| o.value == 'Actually a Novel' }

        refute_nil f
        assert_equal 1, f.hits
      end

      test 'for_field does not include entries for non-existent journals' do
        f = @facets.for_field(:journal_facet).find { |o| o.value == 'Journal of Nothing' }

        assert_nil f
      end

      test 'for_field parses year correctly' do
        f = @facets.for_field(:year).find { |o| o.value == '[2010 TO *]' }

        refute_nil f
        assert_equal 1, f.hits
      end

      test 'for_field does not include entries for non-present years' do
        f = @facets.for_field(:year).find { |o| o.value == '[1940 TO 1949]' }

        assert_nil f
      end

      test 'sorted_for_field works' do
        s = @facets.sorted_for_field(:year)

        assert_equal '[2010 TO *]', s.first.value
        assert_equal '[1850 TO 1859]', s.last.value
      end

      test 'for_query works' do
        refute_nil @facets.for_query('year:[1850 TO 1859]')
        refute_nil @facets.for_query('authors_facet:"C. Dickens"')
      end

      test 'empty works' do
        assert RLetters::Solr::Facets.new(nil, nil).empty?
      end
    end
  end
end
