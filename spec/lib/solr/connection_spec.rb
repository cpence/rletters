# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Solr::Connection do

  # No need to explicitly test Solr::Connection.search, as it's used by
  # basically the entire source base.

  describe '.search_raw' do
    # This is such a vital security requirement that we test it even though
    # it's really a server test
    context 'when fetching external fulltext for a single document' do
      before(:each) do
        @result = Solr::Connection.search_raw(q: 'uid:"gutenberg:3172"',
                                              defType: 'lucene',
                                              tv: 'true',
                                              fl: '*')
      end

      it 'works' do
        expect(@result).to be
      end

      it 'does not store fulltext' do
        doc = @result['response']['docs'][0]
        expect(doc['fulltext']).not_to be
      end

      it 'does not store anything in fulltext_vectors' do
        doc = @result['response']['docs'][0]
        expect(doc['fulltext_vectors']).not_to be
      end

      it 'does store fulltext_url' do
        doc = @result['response']['docs'][0]
        expect(doc['fulltext_url']).to eq('http://www.gutenberg.org/cache/epub/3172/pg3172.txt')
      end
    end

    context 'when searching for the external document' do
      it 'is searchable through fulltext_search' do
        @result = Solr::Connection.search_raw(q: 'fulltext_search:personage',
                                              defType: 'lucene',
                                              fl: '*')
        expect(@result['response']['docs'][0]['uid']).to eq('gutenberg:3172')
      end

      it 'is searchable through fulltext_stem' do
        # PG3172 contains "violated" and "violates" but not "violate"
        @result = Solr::Connection.search_raw(q: 'fulltext_stem:violate',
                                              defType: 'lucene',
                                              fl: '*')
        expect(@result['response']['docs'][0]['uid']).to eq('gutenberg:3172')
      end
    end
  end

  describe '.info' do
    context 'when connection succeeds' do
      it 'gets the relevant data' do
        info = Solr::Connection.info

        expect(info['responseHeader']['status']).to eq(0)
        expect(info['lucene']).to include('solr-spec-version')
        expect(info['system']).to include('name')
      end
    end

    context 'when connection fails' do
      it 'returns an empty hash' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(Solr::Connection.info).to eq({ })
      end
    end
  end

  describe '.ping' do
    it 'works' do
      expect(Solr::Connection.ping).to be_an(Integer)
    end
  end

  describe '.get_solr' do
    it 'successfully responds to changes in cached Solr URL' do
      old_url = Admin::Setting.solr_server_url

      Solr::Connection.send(:get_solr)
      solr = Solr::Connection.solr
      expect(solr.uri).to eq(URI.parse(old_url))

      Admin::Setting.solr_server_url = 'http://1.2.3.4/solr/'
      Solr::Connection.send(:get_solr)
      solr = Solr::Connection.solr
      expect(solr.uri).to eq(URI.parse('http://1.2.3.4/solr/'))

      Admin::Setting.solr_server_url = old_url
    end
  end

end
