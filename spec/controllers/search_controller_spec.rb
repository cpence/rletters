# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchController do
  describe '#index' do
    context 'with empty search results' do
      before(:each) do
        get :index, q: 'fail'
      end

      it 'loads successfully' do
        expect(response).to be_success
      end
    end

    context 'with precise search results' do
      before(:each) do
        get :index
      end

      it 'assigns the search result' do
        expect(assigns(:result)).to be
      end

      it 'assigns the documents variable' do
        expect(assigns(:documents)).to be
      end

      it 'assigns the right number of documents' do
        expect(assigns(:documents).count).to eq(10)
      end

      it 'assigns solr_q' do
        expect(assigns(:solr_q)).to eq('*:*')
      end

      it 'assigns solr_def_type' do
        expect(assigns(:solr_def_type)).to eq('lucene')
      end

      it 'does not assign solr_fq' do
        expect(assigns(:solr_fq)).to be_nil
      end

      it 'sorts by year, descending' do
        expect(assigns(:sort)).to eq('year_sort desc')
      end
    end

    context 'with faceted search results' do
      before(:each) do
        expect(RLetters::Solr::Connection).to receive(:search).and_return(double(documents: []))
        get :index, fq: ['journal_facet:"Journal of Nothing"']
      end

      it 'assigns solr_fq' do
        expect(assigns(:solr_fq)).to be
      end

      it 'sorts by year, descending' do
        expect(assigns(:sort)).to eq('year_sort desc')
      end
    end

    context 'with a dismax search' do
      before(:each) do
        expect(RLetters::Solr::Connection).to receive(:search).and_return(double(documents: []))
        get :index, q: 'testing'
      end

      it 'assigns solr_q' do
        expect(assigns(:solr_q)).to eq('testing')
      end

      it 'assigns solr_def_type' do
        expect(assigns(:solr_def_type)).to eq('dismax')
      end

      it 'does not assign solr_fq' do
        expect(assigns(:solr_fq)).to be_nil
      end

      it 'sorts by score, descending' do
        expect(assigns(:sort)).to eq('score desc')
      end
    end

    context 'with offset and limit parameters' do
      it 'successfully parses those parameters' do
        default_sq = { q: '*:*', def_type: 'lucene', sort: 'year_sort desc', start: 20, rows: 20 }
        expect(RLetters::Solr::Connection).to receive(:search).with(default_sq).and_return(double(documents: []))

        get :index, page: '1', per_page: '20'

        expect(assigns(:documents)).to be_empty
      end

      it 'does not throw an exception on non-integral page values' do
        default_sq = { q: '*:*', def_type: 'lucene', sort: 'year_sort desc', start: 0, rows: 20 }
        expect(RLetters::Solr::Connection).to receive(:search).with(default_sq).and_return(double(documents: []))

        expect {
          get :index, page: 'zzyzzy', per_page: '20'
        }.to_not raise_error
      end

      it 'does not throw an exception on non-integral per_page values' do
        default_sq = { q: '*:*', def_type: 'lucene', sort: 'year_sort desc', start: 10, rows: 10 }
        expect(RLetters::Solr::Connection).to receive(:search).with(default_sq).and_return(double(documents: []))

        expect {
          get :index, page: '1', per_page: 'zzyzzy'
        }.to_not raise_error
      end

      it 'does not let the user specify zero items per page' do
        default_sq = { q: '*:*', def_type: 'lucene', sort: 'year_sort desc', start: 10, rows: 10 }
        expect(RLetters::Solr::Connection).to receive(:search).with(default_sq).and_return(double(documents: []))

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
