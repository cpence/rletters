require 'rails_helper'

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

      it 'does not include anything' do
        expect(@ret.text).to be_empty
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
        @result = described_class.decorate(double('RLetters::Solr::SearchResult', num_hits: 100, params: {}))
      end

      it 'returns "in database"' do
        expect(@result.num_hits).to eq('100 articles in database')
      end
    end

    context 'when a search has been performed' do
      before(:example) do
        @result = described_class.decorate(
          double(
            'RLetters::Solr::SearchResult',
            num_hits: 100,
            params: { q: 'Test search' }
          )
        )
      end

      it 'returns "found"' do
        expect(@result.num_hits).to eq('100 articles found')
      end
    end

    context 'when a faceted query has been performed' do
      before(:example) do
        @result = described_class.decorate(
          double(
            'RLetters::Solr::SearchResult',
            num_hits: 100,
            params: { fq: ['journal:(PLoS Neglected Tropical Diseases)'] }
          )
        )
      end

      it 'returns "found"' do
        expect(@result.num_hits).to eq('100 articles found')
      end
    end
  end

  describe '#sort' do
    before(:example) do
      @result = described_class.decorate(double('RLetters::Solr::SearchResult', params: { 'sort' => 'score desc' }))
    end

    it 'reads the sort method from the params' do
      expect(@result.sort).to eq('Sort: Relevance')
    end
  end

  describe '#sort_methods' do
    it 'works as expected' do
      @result = described_class.decorate(double('RLetters::Solr::SearchResult', params: { 'sort' => 'score desc' }))
      expect(@result.sort_methods.assoc('score desc')[1]).to eq('Sort: Relevance')
      expect(@result.sort_methods.assoc('title_sort asc')[1]).to eq('Sort: Title (ascending)')
      expect(@result.sort_methods.assoc('journal_sort desc')[1]).to eq('Sort: Journal (descending)')
      expect(@result.sort_methods.assoc('year_sort asc')[1]).to eq('Sort: Year (ascending)')
      expect(@result.sort_methods.assoc('authors_sort desc')[1]).to eq('Sort: Authors (descending)')
    end
  end

  describe '#documents' do
    before(:example) do
      params = {
        q: '*:*',
        defType: 'lucene'
      }
      @result = RLetters::Solr::Connection.search(params)
      @decorated = described_class.decorate(@result)
    end

    it 'returns a set of decorated documents' do
      expect(@decorated.documents).to be_an(Array)
      expect(@decorated.documents[0]).to be_decorated
    end
  end

  describe '#categories' do
    context 'with categories' do
      before do
        params = {
          q: '*:*',
          defType: 'lucene'
        }
        @result = RLetters::Solr::Connection.search(params)
        @decorated = described_class.decorate(@result)
      end

      it 'returns a categories decorator for all' do
        @category = create(:category)
        expect(Documents::Category).to receive(:all).at_least(:once).and_return([@category])
        expect(@decorated.categories).to be_decorated
        expect(@decorated.categories[0]).to eq(@category)
        expect(@decorated.categories[0]).to be_decorated
      end
    end

    context 'without categories' do
      before do
        params = {
          q: '*:*',
          defType: 'lucene'
        }
        @result = RLetters::Solr::Connection.search(params)
        @decorated = described_class.decorate(@result)
      end

      it 'returns nil' do
        expect(Documents::Category).to receive(:all).and_return([])
        expect(@decorated.categories).to be_nil
      end
    end
  end
end
