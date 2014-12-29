require 'spec_helper'

RSpec.describe SearchController, type: :controller do
  describe '#index' do
    context 'with empty search results' do
      before(:example) do
        get :index, q: 'fail'
      end

      it 'loads successfully' do
        expect(response).to be_success
      end
    end

    context 'with empty search results' do
      before(:example) do
        get :index
      end

      it 'assigns the search result' do
        expect(assigns(:result)).to be
      end

      it 'sorts by year, descending' do
        expect(assigns(:result).params['sort']).to eq('year_sort desc')
      end
    end

    context 'with faceted search results' do
      it 'sorts by year, descending' do
        params = {
          q: '*:*',
          fq: ['journal_facet:"Journal of Nothing"'],
          def_type: 'lucene',
          sort: 'year_sort desc',
          start: 0,
          rows: 10
        }

        expect(RLetters::Solr::Connection).to receive(:search).with(params).and_return(double('RLetters::Solr::SearchResult', documents: [], facets: nil, params: params.stringify_keys))
        get :index, fq: ['journal_facet:"Journal of Nothing"']
      end
    end

    context 'with a dismax search' do
      it 'sorts by score, descending' do
        params = {
          q: 'testing',
          def_type: 'dismax',
          sort: 'score desc',
          start: 0,
          rows: 10
        }

        expect(RLetters::Solr::Connection).to receive(:search).with(params).and_return(double('RLetters::Solr::SearchResult', documents: [], facets: nil, params: params.stringify_keys))
        get :index, q: 'testing'
      end
    end

    context 'with offset and limit parameters' do
      it 'successfully parses those parameters' do
        default_sq = { q: '*:*', def_type: 'lucene', sort: 'year_sort desc', start: 20, rows: 20 }
        expect(RLetters::Solr::Connection).to receive(:search).with(default_sq).and_return(double('RLetters::Solr::SearchResult', documents: [], facets: nil, params: default_sq.stringify_keys))

        get :index, page: '1', per_page: '20'

        expect(assigns(:result).documents).to be_empty
      end

      it 'does not throw an exception on non-integral page values' do
        default_sq = { q: '*:*', def_type: 'lucene', sort: 'year_sort desc', start: 0, rows: 20 }
        expect(RLetters::Solr::Connection).to receive(:search).with(default_sq).and_return(double('RLetters::Solr::SearchResult', documents: [], facets: nil, params: default_sq.stringify_keys))

        expect {
          get :index, page: 'zzyzzy', per_page: '20'
        }.to_not raise_error
      end

      it 'does not throw an exception on non-integral per_page values' do
        default_sq = { q: '*:*', def_type: 'lucene', sort: 'year_sort desc', start: 10, rows: 10 }
        expect(RLetters::Solr::Connection).to receive(:search).with(default_sq).and_return(double('RLetters::Solr::SearchResult', documents: [], facets: nil, params: default_sq.stringify_keys))

        expect {
          get :index, page: '1', per_page: 'zzyzzy'
        }.to_not raise_error
      end

      it 'does not let the user specify zero items per page' do
        default_sq = { q: '*:*', def_type: 'lucene', sort: 'year_sort desc', start: 10, rows: 10 }
        expect(RLetters::Solr::Connection).to receive(:search).with(default_sq).and_return(double('RLetters::Solr::SearchResult', documents: [], facets: nil, params: default_sq.stringify_keys))

        get :index, page: '1', per_page: '0'
      end
    end
  end

  describe '#advanced' do
    it 'loads successfully' do
      get :advanced
      expect(response).to be_success
    end
  end
end
