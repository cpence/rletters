# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe SearchResultDecorator, type: :decorator do
  include Capybara::RSpecMatchers

  describe '#filter_removal_links' do
    context 'with nothing active' do
      before(:example) do
        params = {
          q: '*:*',
          defType: 'lucene'
        }
        @result = RLetters::Solr::Connection.search(params)
        @decorated = described_class.decorate(@result)
        @ret = Capybara.string(@decorated.filter_removal_links)
      end

      it 'includes the no-facet text' do
        expect(@ret).to have_content('No filters active')
      end
    end

    context 'with a facet active' do
      before(:example) do
        params = {
          q: '*:*',
          defType: 'lucene',
          fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']
        }
        Draper::ViewContext.current.params[:fq] = ['journal_facet:"PLoS Neglected Tropical Diseases"']
        @result = RLetters::Solr::Connection.search(params)
        @decorated = described_class.decorate(@result)
        @ret = Capybara.string(@decorated.filter_removal_links)
      end

      it 'includes the removal link' do
        expect(@ret).to have_css('a[href="/search"]',
                                 text: 'Journal: PLoS Neglected Tropical Diseases')
      end
    end

    context 'with a category active' do
      before(:example) do
        @category = create(:category)
        params = {
          q: '*:*',
          defType: 'lucene',
          categories: [@category.to_param],
          fq: ['journal_facet:("PLoS Neglected Tropical Diseases")']
        }
        Draper::ViewContext.current.params[:categories] = [@category.to_param]
        @result = RLetters::Solr::Connection.search(params)
        @decorated = described_class.decorate(@result)
        @ret = Capybara.string(@decorated.filter_removal_links)
      end

      it 'includes the removal link' do
        expect(@ret).to have_css('a[href="/search"]',
                                 text: 'Category: Test Category')
      end
    end

    context 'with overlapping facet and category active' do
      before(:example) do
        @category = create(:category)
        params = {
          q: '*:*',
          defType: 'lucene',
          categories: [@category.to_param],
          fq: ['journal_facet:("PLoS Neglected Tropical Diseases")', 'journal_facet:"PLoS Neglected Tropical Diseases"']
        }
        Draper::ViewContext.current.params[:categories] = [@category.to_param]
        Draper::ViewContext.current.params[:fq] = ['journal_facet:"PLoS Neglected Tropical Diseases"']
        @result = RLetters::Solr::Connection.search(params)
        @decorated = described_class.decorate(@result)
        @ret = Capybara.string(@decorated.filter_removal_links)
      end

      it 'includes the category removal link (with facet)' do
        expect(@ret).to have_css('a[href="/search?fq%5B%5D=journal_facet%3A%22PLoS+Neglected+Tropical+Diseases%22"]',
                                 text: 'Category: Test Category')
      end

      it 'includes the facet removal link (with category)' do
        expect(@ret).to have_css("a[href='/search?categories%5B%5D=#{@category.to_param}']",
                                 text: 'Journal: PLoS Neglected Tropical Diseases')
      end
    end
  end

  describe '#num_hits' do
    context 'when no search has been performed' do
      before(:example) do
        @result = described_class.decorate(double("RLetters::Solr::SearchResult", num_hits: 100, params: {}))
      end

      it 'returns "in database"' do
        expect(@result.num_hits).to eq('100 articles in database')
      end
    end

    context 'when a search has been performed' do
      before(:example) do
        @result = described_class.decorate(double(
          "RLetters::Solr::SearchResult",
          num_hits: 100,
          params: { q: 'Test search' }
        ))
      end

      it 'returns "found"' do
        expect(@result.num_hits).to eq('100 articles found')
      end
    end

    context 'when a faceted query has been performed' do
      before(:example) do
        @result = described_class.decorate(double(
          "RLetters::Solr::SearchResult",
          num_hits: 100,
          params: { fq: ['journal:(PLoS Neglected Tropical Diseases)'] }
        ))
      end

      it 'returns "found"' do
        expect(@result.num_hits).to eq('100 articles found')
      end
    end
  end

  describe '#pagination' do
    context 'when we only have one page of results' do
      before(:example) do
        @result = described_class.decorate(double("RLetters::Solr::SearchResult", num_hits: 1, params: { 'rows' => 10 }))
      end

      it 'returns no links' do
        expect(@result.pagination).not_to have_selector('a')
      end
    end

    context 'when we have only one flat range of results' do
      before(:example) do
        @result = described_class.decorate(double("RLetters::Solr::SearchResult", num_hits: 49, params: { 'rows' => 10 }))
        @ret = @result.pagination
      end

      it 'has links for all the pages included' do
        (1..4).each do |n|
          expect(@ret).to have_selector("a[href=\"/search?page=#{n}\"]",
                                        text: (n + 1).to_s)
        end
      end
    end

    context 'when we have more than one page of results' do
      context 'when we are on the first page' do
        before(:example) do
          @result = described_class.decorate(double("RLetters::Solr::SearchResult", num_hits: 100, params: { 'rows' => 10 }))
          @ret = @result.pagination
        end

        it 'returns forward buttons' do
          expect(@ret).to have_selector('a[href="/search?page=1"]', text: '»')
          expect(@ret).to have_selector('a[href="/search?page=9"]', text: '10')
        end

        it 'does not return back buttons' do
          expect(@ret).to have_selector('a[href="#"]', text: '«')
        end
      end

      context 'when we are in the middle' do
        before(:example) do
          @result = described_class.decorate(double("RLetters::Solr::SearchResult", num_hits: 100, params: { 'start' => 50, 'rows' => 10 }))
          @ret = @result.pagination
        end

        it 'returns back buttons' do
          expect(@ret).to have_selector('a[href="/search?page=4"]', text: '«')
          expect(@ret).to have_selector('a[href="/search"]', text: '1')
        end

        it 'returns forward buttons' do
          expect(@ret).to have_selector('a[href="/search?page=6"]', text: '»')
          expect(@ret).to have_selector('a[href="/search?page=9"]', text: '10')
        end
      end

      context 'when we are on the last page' do
        before(:example) do
          @result = described_class.decorate(double("RLetters::Solr::SearchResult", num_hits: 100, params: { 'start' => 90, 'rows' => 10 }))
          @ret = @result.pagination
        end

        it 'returns back buttons' do
          expect(@ret).to have_selector('a[href="/search?page=8"]', text: '«')
          expect(@ret).to have_selector('a[href="/search"]', text: '1')
        end

        it 'does not return forward buttons' do
          expect(@ret).to have_selector('a[href="#"]', text: '»')
        end
      end
    end
  end

  describe '#sort' do
    before(:example) do
      @result = described_class.decorate(double("RLetters::Solr::SearchResult", params: { 'sort' => 'score desc' }))
    end

    it 'reads the sort method from the params' do
      expect(@result.sort).to eq('Sort: Relevance')
    end
  end

  describe '#sort_methods' do
    it 'works as expected' do
      @result = described_class.decorate(double("RLetters::Solr::SearchResult", params: { 'sort' => 'score desc' }))
      expect(@result.sort_methods.assoc('score desc')[1]).to eq('Sort: Relevance')
      expect(@result.sort_methods.assoc('title_sort asc')[1]).to eq('Sort: Title (ascending)')
      expect(@result.sort_methods.assoc('journal_sort desc')[1]).to eq('Sort: Journal (descending)')
      expect(@result.sort_methods.assoc('year_sort asc')[1]).to eq('Sort: Year (ascending)')
      expect(@result.sort_methods.assoc('authors_sort desc')[1]).to eq('Sort: Authors (descending)')
    end
  end
end
