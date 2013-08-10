# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Solr::Connection do

  # No need to explicitly test Solr::Connection.find, as it's used by basically
  # the entire source base.

  describe '.info' do
    context 'when connection succeeds', vcr: { cassette_name: 'info_connection_success' } do
      it 'gets the relevant data' do
        info = Solr::Connection.info

        expect(info['responseHeader']['status']).to eq(0)
        expect(info['lucene']).to include('solr-spec-version')
        expect(info['system']).to include('name')
      end
    end

    context 'when connection fails' do
      it 'returns an empty hash' do
        stub_request(:any, /127\.0\.0\.1/).to_timeout
        expect(Solr::Connection.info).to eq({ })
      end
    end
  end

  describe '.get_solr' do
    it 'successfully responds to changes in cached Solr URL' do
      old_url = Setting.solr_server_url

      Solr::Connection.send(:get_solr)
      solr = Solr::Connection.solr
      expect(solr.uri).to eq(URI.parse(old_url))

      Setting.solr_server_url = 'http://1.2.3.4/solr/'
      Solr::Connection.send(:get_solr)
      solr = Solr::Connection.solr
      expect(solr.uri).to eq(URI.parse('http://1.2.3.4/solr/'))

      Setting.solr_server_url = old_url
    end
  end

end
