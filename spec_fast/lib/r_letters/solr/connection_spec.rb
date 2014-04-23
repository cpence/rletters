# -*- encoding : utf-8 -*-
require 'net/http'
require 'rsolr'
require 'core_ext/net/http_exceptions'
require 'active_support/core_ext/string/inflections'
require 'r_letters/solr/connection'

require 'support/doubles/setting'
require 'support/doubles/logger'

describe RLetters::Solr::Connection do
  before(:each) do
    stub_logger

    stub_const('RSolr::Ext', Module.new)
    stub_const('RSolr::Ext::Response', Module.new)
    stub_const('RSolr::Ext::Response::Base', Class.new)

    stub_const('RLetters::Solr::SearchResult', Class.new)

    double_setting(:solr_timeout, 60)
    double_setting(:solr_server_url, 'http://1.2.3.4/solr/')

    # Defeat the Solr instance caching, except for when we explicitly want to
    # test it
    described_class.instance_variable_set(:@solr, nil)
  end

  describe '.search' do
    it 'wraps results in a response object' do
      expect(RSolr::Ext::Response::Base).to receive(:new).with({ response: 'goes here' },
                                                               'search',
                                                               { params: 'original' }).and_return('rsolr ext response')

      expect(described_class).to receive(:search_raw).with({ params: 'original' }).and_return({ response: 'goes here' })
      expect(RLetters::Solr::SearchResult).to receive(:new).with('rsolr ext response').and_return('search result')
      expect(described_class.search(params: 'original')).to eq('search result')
    end

    it 'replaces params with a default if Solr fails' do
      expect(RSolr::Ext::Response::Base).to receive(:new).with(kind_of(Hash),
                                                               'search',
                                                               { params: 'original' }).and_return('rsolr ext response')

      # Stubbing search_raw to return an empty hash replicates a Solr failure
      expect(described_class).to receive(:search_raw).with({ params: 'original' }).and_return({})
      expect(RLetters::Solr::SearchResult).to receive(:new).with('rsolr ext response').and_return('search result')
      expect(described_class.search(params: 'original')).to eq('search result')
    end
  end

  describe '.search_raw' do
    it 'returns an empty hash when Solr fails' do
      mock_solr = double
      expect(mock_solr).to receive(:post).with(any_args()).and_raise(Timeout::Error.new)
      expect(RSolr::Ext).to receive(:connect).with(any_args()).and_return(mock_solr)

      expect(described_class.search_raw(q: '')).to eq({})
    end

    it 'successfully responds to changes in cached Solr URL' do
      mock_solr = double
      allow(mock_solr).to receive(:post).and_return(true)

      expect(RSolr::Ext).to receive(:connect).with(url: 'http://1.2.3.4/solr/',
                                                   read_timeout: 60,
                                                   open_timeout: 60).and_return(mock_solr)

      described_class.search_raw({})

      double_setting(:solr_server_url, 'http://5.6.7.8/solr/')
      expect(RSolr::Ext).to receive(:connect).with(url: 'http://5.6.7.8/solr/',
                                                   read_timeout: 60,
                                                   open_timeout: 60).and_return(mock_solr)

      described_class.search_raw({})
    end

    it 'converts snake_case Symbol params into camelCase String params' do
      mock_solr = double
      expect(mock_solr).to receive(:post).with('search', data: { 'defType' => 'asdf' }).and_return(true)
      allow(RSolr::Ext).to receive(:connect).with(any_args()).and_return(mock_solr)

      described_class.search_raw(def_type: 'asdf')
    end
  end

  describe '.info' do
    context 'when connection succeeds' do
      it 'hits the right path on the Solr server' do
        mock_solr = double
        expect(mock_solr).to receive(:get).with('admin/system').and_return({ arbitrary: 'response' })
        expect(RSolr::Ext).to receive(:connect).with(any_args()).and_return(mock_solr)

        expect(described_class.info).to eq({ arbitrary: 'response' })
      end
    end

    context 'when connection fails' do
      it 'returns an empty hash' do
        mock_solr = double
        expect(mock_solr).to receive(:get).with(any_args()).and_raise(Timeout::Error.new)
        expect(RSolr::Ext).to receive(:connect).with(any_args()).and_return(mock_solr)

        expect(described_class.info).to eq({})
      end
    end
  end

  describe '.ping' do
    it 'works' do
      mock_solr = double
      expect(mock_solr).to receive(:post).with('search', data: { q: '*:*', start: 0, rows: 0, 'defType' => 'lucene' }).and_return({ 'responseHeader' => { 'QTime' => 1337 } })
      expect(RSolr::Ext).to receive(:connect).with(any_args()).and_return(mock_solr)

      expect(described_class.ping).to eq(1337)
    end
  end
end
