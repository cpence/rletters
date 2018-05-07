# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Solr
    class SearchTest < ActiveSupport::TestCase
      test 'eliminates blank params' do
        params = { q: '', advanced: '' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal '*:*', ret[:q]
        assert_equal 'lucene', ret[:def_type]
      end

      test 'copies over faceted browsing paramters' do
        params = { q: '*:*', advanced: 'true',
                   fq: ['authors_facet:W. Shatner',
                        'journal_facet:Astrobiology'] }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'authors_facet:W. Shatner', ret[:fq][0]
        assert_equal 'journal_facet:Astrobiology', ret[:fq][1]
      end

      test 'does the right thing with categories' do
        category = ::Documents::Category.create(name: 'Test Category', journals: ['Gutenberg', 'PLoS Neglected Tropical Diseases'])
        params = { q: '*:*', advanced: 'true', categories: [category.to_param] }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'journal_facet:("Gutenberg" OR "PLoS Neglected Tropical Diseases")', ret[:fq][0]
      end

      test 'works with empty categories' do
        category = ::Documents::Category.create(name: 'Empty Category')
        params = { q: '*:*', advanced: 'true', categories: [category.to_param] }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_nil ret[:fq]
      end

      test 'works with empty and full categories' do
        category_1 = ::Documents::Category.create(name: 'Test Category', journals: ['Gutenberg', 'PLoS Neglected Tropical Diseases'])
        category_2 = ::Documents::Category.create(name: 'Empty Category')
        params = { q: '*:*', advanced: 'true', categories: [category_1.to_param, category_2.to_param] }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'journal_facet:("Gutenberg" OR "PLoS Neglected Tropical Diseases")', ret[:fq][0]
      end

      test 'puts together empty advanced search correctly' do
        params = { q: '', advanced: 'true' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal '*:*', ret[:q]
        assert_equal 'lucene', ret[:def_type]
      end

      test 'copies generic advanced search content correctly' do
        params = { q: 'test', advanced: 'true' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'test', ret[:q]
      end

      test 'combines the search terms with the boolean values' do
        params = { advanced: 'true', field_0: 'volume', value_0: '30',
                   boolean_0: 'and', field_1: 'number', value_1: '5',
                   boolean_1: 'or', field_2: 'pages', value_2: '300-301' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'volume:"30" AND number:"5" OR pages:"300-301"', ret[:q]
      end

      test 'mixes in verbatim search parameters correctly' do
        params = { advanced: 'true', field_0: 'authors', value_0: 'W. Shatner',
                   boolean_0: 'and', field_1: 'volume', value_1: '30',
                   boolean_1: 'and', field_2: 'number', value_2: '5',
                   boolean_2: 'and', field_3: 'pages', value_3: '300-301' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'authors:(("W* Shatner"))'
        assert_includes ret[:q], 'volume:"30"'
        assert_includes ret[:q], 'number:"5"'
        assert_includes ret[:q], 'pages:"300-301"'
      end

      test 'handles fuzzy params with type set to verbatim' do
        params = { advanced: 'true', field_0: 'journal_exact',
                   value_0: 'Astrobiology', boolean_0: 'and',
                   field_1: 'title_exact', value_1: 'Testing with Spaces',
                   boolean_1: 'and', field_2: 'fulltext_exact',
                   value_2: 'alien' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'journal:"Astrobiology"'
        assert_includes ret[:q], 'title:"Testing with Spaces"'
        assert_includes ret[:q], 'fulltext_search:"alien"'
      end

      test 'handles fuzzy params with type set to fuzzy' do
        params = { advanced: 'true', field_0: 'journal_fuzzy',
                   value_0: 'Astrobiology', boolean_0: 'and',
                   field_1: 'title_fuzzy', value_1: 'Testing with Spaces',
                   boolean_1: 'and', field_2: 'fulltext_fuzzy',
                   value_2: 'alien' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'journal_stem:"Astrobiology"'
        assert_includes ret[:q], 'title_stem:"Testing with Spaces"'
        assert_includes ret[:q], 'fulltext_stem:"alien"'
      end

      test 'handles multiple authors correctly' do
        params = { advanced: 'true', field_0: 'authors',
                   value_0: 'W. Shatner, J. Doe' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'authors:(("W* Shatner") AND ("J* Doe"))'
      end

      test 'handles Lucene name forms correctly' do
        params = { advanced: 'true', field_0: 'authors',
                   value_0: 'Joe John Public' }
        ret = RLetters::Solr::Search.params_to_query(params)

        # No need to test all of these, just hit a couple
        assert_includes ret[:q], '"Joe Public"'
        assert_includes ret[:q], '"J Public"'
        assert_includes ret[:q], '"JJ Public"'
        assert_includes ret[:q], '"J John Public"'
      end

      test 'handles only single year' do
        params = { advanced: 'true', field_0: 'year_ranges', value_0: '1900' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'year:(1900)'
      end

      test 'handles year range with dash' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: '1900 - 1910' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'year:([1900 TO 1910])'
      end

      test 'handles year range with hyphen' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: '1900-1910' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'year:([1900 TO 1910])'
      end

      test 'handles multiple single years' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: '1900, 1910' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'year:(1900 OR 1910)'
      end

      test 'handles single years with ranges' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: '1900, 1910-1920, 1930' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_includes ret[:q], 'year:(1900 OR [1910 TO 1920] OR 1930)'
      end

      test 'rejects non-numeric year params' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: 'asdf, wut-asf, 1-2-523' }
        ret = RLetters::Solr::Search.params_to_query(params)

        refute_includes ret[:q], 'year:('
      end

      test 'correctly copies dismax search' do
        params = { q: 'test' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'test', ret[:q]
        assert_equal 'dismax', ret[:def_type]
      end

      test 'ignores page and per_page for non-API searches' do
        params = { page: '1', per_page: '20' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_nil ret[:start]
        assert_equal 16, ret[:rows]
      end

      test 'sets the initial cursor mark for non-API searches' do
        params = { q: 'test' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal '*', ret[:cursor_mark]
      end

      test 'copies the non-initial cursor mark for non-API searches' do
        params = { q: 'test', cursor_mark: 'asdf' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'asdf', ret[:cursor_mark]
      end

      test 'sorts by year, descending, by default' do
        params = {}
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'year_sort desc,uid asc', ret[:sort]
      end

      test 'sorts by year, descending, with just a facet query' do
        params = { fq: ['journal_facet:"Journal of Nothing"'] }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'year_sort desc,uid asc', ret[:sort]
      end

      test 'sorts by score, descending, for a basic dismax search' do
        params = { q: 'testing' }
        ret = RLetters::Solr::Search.params_to_query(params)

        assert_equal 'score desc,uid asc', ret[:sort]
      end

      test 'successfully parses page and per_page parameters for API searches' do
        params = { page: '1', per_page: '20' }
        ret = RLetters::Solr::Search.params_to_query(params, true)

        assert_equal 20, ret[:start]
        assert_equal 20, ret[:rows]
      end

      test 'clamps non-integral page values for API searches' do
        params = { page: 'zzyzzy', per_page: '20' }
        ret = RLetters::Solr::Search.params_to_query(params, true)

        assert_equal 0, ret[:start]
        assert_equal 20, ret[:rows]
      end

      test 'clamps non-integral per_page values for API searches' do
        params = { page: '1', per_page: 'zzyzzy' }
        ret = RLetters::Solr::Search.params_to_query(params, true)

        assert_equal 10, ret[:start]
        assert_equal 10, ret[:rows]
      end

      test 'rounds up zero items per page for API searches' do
        params = { page: '1', per_page: '0' }
        ret = RLetters::Solr::Search.params_to_query(params, true)

        assert_equal 10, ret[:start]
        assert_equal 10, ret[:rows]
      end

      test 'does not include a cursor mark by default for API searches' do
        params = {}
        ret = RLetters::Solr::Search.params_to_query(params, true)

        assert_nil ret[:cursor_mark]
      end

      test 'does not include a cursor mark even when passed one for API searches' do
        params = { cursor_mark: 'asdf' }
        ret = RLetters::Solr::Search.params_to_query(params, true)

        assert_nil ret[:cursor_mark]
      end

      test 'does not include UID in the sort fields for API searches' do
        params = {}
        ret = RLetters::Solr::Search.params_to_query(params, true)

        assert_equal 'year_sort desc', ret[:sort]
      end
    end
  end
end
