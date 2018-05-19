# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Presenters
    class SearchResultPresenterTest < ActiveSupport::TestCase
      test 'next_page_params returns nil without another page' do
        r = stub(solr_response: { 'nextCursorMark' => 'mark' })
        p = ActionController::Parameters.new(cursor_mark: 'mark')
        pres = RLetters::Presenters::SearchResultPresenter.new(result: r)

        assert_nil pres.next_page_params(p)
      end

      test 'next_page_params moves mark' do
        r = stub(solr_response: { 'nextCursorMark' => 'mark_new' })
        p = ActionController::Parameters.new(cursor_mark: 'mark')
        pres = RLetters::Presenters::SearchResultPresenter.new(result: r)

        assert_equal 'mark_new', pres.next_page_params(p)[:cursor_mark]
      end

      test 'num_hits_string returns "in database" without search' do
        r = stub(num_hits: 100, params: {})
        pres = RLetters::Presenters::SearchResultPresenter.new(result: r)

        assert_equal '100 articles in database', pres.num_hits_string
      end

      test 'num_hits_string returns "found" with search' do
        r = stub(num_hits: 100, params: { q: 'Test search' })
        pres = RLetters::Presenters::SearchResultPresenter.new(result: r)

        assert_equal '100 articles found', pres.num_hits_string
      end

      test 'num_hits_string returns "found" with faceting' do
        r = stub(num_hits: 100,
                 params: { fq: ['journal:(PLoS Neglected Tropical Diseases)'] })
        pres = RLetters::Presenters::SearchResultPresenter.new(result: r)

        assert_equal '100 articles found', pres.num_hits_string
      end

      test 'current_sort_method works' do
        r = stub(params: { 'sort' => 'score desc' })
        pres = RLetters::Presenters::SearchResultPresenter.new(result: r)

        assert_equal 'Sort: Relevance', pres.current_sort_method
      end

      test 'current_sort_method works for unknown methods' do
        r = stub(params: { 'sort' => 'nope desc' })
        pres = RLetters::Presenters::SearchResultPresenter.new(result: r)

        assert_equal 'Unknown', pres.current_sort_method
      end

      test 'sort_methods works' do
        r = stub(params: { 'sort' => 'score desc' })
        pres = RLetters::Presenters::SearchResultPresenter.new(result: r)

        assert_equal 'Sort: Relevance', pres.sort_methods.assoc('score desc')[1]
        assert_equal 'Sort: Title (ascending)', pres.sort_methods.assoc('title_sort asc')[1]
        assert_equal 'Sort: Journal (descending)', pres.sort_methods.assoc('journal_sort desc')[1]
        assert_equal 'Sort: Year (ascending)', pres.sort_methods.assoc('year_sort asc')[1]
        assert_equal 'Sort: Authors (descending)', pres.sort_methods.assoc('authors_sort desc')[1]
      end
    end
  end
end
