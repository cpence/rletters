require 'rails_helper'

RSpec.describe RLetters::Presenters::SearchResultPresenter do
  describe '#num_hits_string' do
    context 'when no search has been performed' do
      before(:example) do
        @result = double('RLetters::Solr::SearchResult', num_hits: 100, params: {})
        @presenter = described_class.new(result: @result)
      end

      it 'returns "in database"' do
        expect(@presenter.num_hits_string).to eq('100 articles in database')
      end
    end

    context 'when a search has been performed' do
      before(:example) do
        @result = double(
          'RLetters::Solr::SearchResult',
          num_hits: 100,
          params: { q: 'Test search' }
        )
        @presenter = described_class.new(result: @result)
      end

      it 'returns "found"' do
        expect(@presenter.num_hits_string).to eq('100 articles found')
      end
    end

    context 'when a faceted query has been performed' do
      before(:example) do
        @result = double(
          'RLetters::Solr::SearchResult',
          num_hits: 100,
          params: { fq: ['journal:(PLoS Neglected Tropical Diseases)'] }
        )
        @presenter = described_class.new(result: @result)
      end

      it 'returns "found"' do
        expect(@presenter.num_hits_string).to eq('100 articles found')
      end
    end
  end

  describe '#current_sort_method' do
    before(:example) do
      @result = double('RLetters::Solr::SearchResult', params: { 'sort' => 'score desc' })
      @presenter = described_class.new(result: @result)
    end

    it 'reads the sort method from the params' do
      expect(@presenter.current_sort_method).to eq('Sort: Relevance')
    end
  end

  describe '#sort_methods' do
    it 'works as expected' do
      @result = double('RLetters::Solr::SearchResult', params: { 'sort' => 'score desc' })
      @presenter = described_class.new(result: @result)
      expect(@presenter.sort_methods.assoc('score desc')[1]).to eq('Sort: Relevance')
      expect(@presenter.sort_methods.assoc('title_sort asc')[1]).to eq('Sort: Title (ascending)')
      expect(@presenter.sort_methods.assoc('journal_sort desc')[1]).to eq('Sort: Journal (descending)')
      expect(@presenter.sort_methods.assoc('year_sort asc')[1]).to eq('Sort: Year (ascending)')
      expect(@presenter.sort_methods.assoc('authors_sort desc')[1]).to eq('Sort: Authors (descending)')
    end
  end
end
