# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Solr::SearchResult' do

  describe '#solr_response' do
    it 'returns an RSolr::Ext::Response' do
      result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
      expect(result.solr_response).to be_a(RSolr::Ext::Response::Base)
    end
  end

  describe '#documents' do
    context 'when loading a set of documents' do
      before(:each) do
        @result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
      end

      it 'loads all of the documents' do
        expect(@result.documents.count).to eq(10)
      end
    end

    context 'when no documents are returned' do
      it 'returns an empty array' do
        expect(Solr::Connection.search({ q: 'uid:"fail"', defType: 'lucene' }).documents).to be_empty
      end
    end

    context 'when Solr times out' do
      it 'raises an error' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect { Solr::Connection.search({ q: 'uid:"fail"', defType: 'lucene' }) }.to raise_error(StandardError)
      end
    end
  end

  describe '#num_hits' do
    context 'when loading one document' do
      before(:each) do
        @result = Solr::Connection.search({ q: 'uid:"doi:10.1111/j.1439-0310.2008.01576.x"', defType: 'lucene' })
      end

      it 'sets num_hits to 1' do
        expect(@result.num_hits).to eq(1)
      end
    end

    context 'when loading a set of documents' do
      before(:each) do
        @result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
      end

      it 'sets num_hits' do
        expect(@result.num_hits).to eq(1043)
      end
    end
  end

  describe '#facets' do
    context 'when loading a set of documents' do
      before(:each) do
        @result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
      end

      it 'sets the facets' do
        expect(@result.facets.all).to be_present
        expect(@result.facets).not_to be_empty
      end
    end
  end
end
