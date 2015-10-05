require 'spec_helper'

RSpec.describe RLetters::Solr::Connection do
  describe '.search' do
    it 'wraps results in a search result object' do
      expect(described_class.search(q: '*:*')).to be_a(RLetters::Solr::SearchResult)
    end
  end

  describe '.search_raw' do
    it 'returns an empty hash when Solr fails' do
      stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
      expect(described_class.search_raw(q: '')).to eq({})
    end

    it 'converts snake_case Symbol params into camelCase String params' do
      header = described_class.search_raw(def_type: 'lucene')['responseHeader']
      expect(header['params']['defType']).to eq('lucene')
    end
  end

  describe '.info' do
    context 'when connection succeeds' do
      it 'hits the right path on the Solr server' do
        expect_any_instance_of(RSolr::Client).to receive(:get).with('admin/system')
        described_class.info
      end
    end

    context 'when connection fails' do
      it 'returns an empty hash' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(described_class.info).to eq({})
      end
    end
  end

  describe '.ping' do
    it 'returns nil when Solr fails' do
      stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
      expect(described_class.ping).to be_nil
    end

    it 'works' do
      expect(described_class.ping).to be_an(Integer)
    end
  end
end
