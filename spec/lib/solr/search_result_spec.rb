# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Solr::SearchResult' do

  describe '#solr_response', vcr: { cassette_name: 'solr_default' } do
    it 'returns an RSolr::Ext::Response' do
      result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
      expect(result.solr_response).to be_a(RSolr::Ext::Response::Base)
    end
  end

  describe '#documents' do
    context 'when loading a set of documents',
            vcr: { cassette_name: 'solr_default' } do
      before(:each) do
        @result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
      end

      it 'loads all of the documents' do
        expect(@result.documents).to have(10).items
      end
    end

    context 'when no documents are returned',
            vcr: { cassette_name: 'solr_fail' } do
      it 'returns an empty array' do
        expect(Solr::Connection.search({ q: 'shasum:fail', defType: 'lucene' }).documents).to have(0).items
      end
    end

    context 'when Solr times out' do
      it 'raises an error' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect { Solr::Connection.search({ q: 'shasum:fail', defType: 'lucene' }) }.to raise_error(StandardError)
      end
    end
  end

  describe '#num_hits' do
    context 'when loading one document',
            vcr: { cassette_name: 'solr_single' } do
      before(:each) do
        @result = Solr::Connection.search({ q: 'shasum:00972c5123877961056b21aea4177d0dc69c7318', defType: 'lucene' })
      end

      it 'sets num_hits to 1' do
        expect(@result.num_hits).to eq(1)
      end
    end

    context 'when loading a set of documents',
            vcr: { cassette_name: 'solr_default' } do
      before(:each) do
        @result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
      end

      it 'sets num_hits' do
        expect(@result.num_hits).to eq(1042)
      end
    end
  end

  describe '#facets' do
    context 'when loading a set of documents',
            vcr: { cassette_name: 'solr_default' } do
      before(:each) do
        @result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
      end

      it 'sets the facets' do
        expect(@result.facets.all).to have_at_least(1).facet
        expect(@result.facets).not_to be_empty
      end
    end
  end
end
