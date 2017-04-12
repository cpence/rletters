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

  # This is such a vital security requirement that we test it anyway.
  # FIXME: This is probably stupid, but I'm keeping it for the moment.
  context 'when fetching external fulltext for a single document' do
    before(:example) do
      @result = described_class.search_raw(q: 'uid:"gutenberg:3172"',
                                           def_type: 'lucene',
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
      @result = described_class.search_raw(q: 'fulltext_search:personage',
                                           def_type: 'lucene',
                                           fl: '*')
      uids = @result['response']['docs'].map { |d| d['uid'] }
      expect(uids).to include('gutenberg:3172')
    end

    it 'is searchable through fulltext_stem' do
      # PG3172 contains "violated" and "violates" but not "violate"
      @result = described_class.search_raw(q: 'fulltext_stem:violate',
                                           def_type: 'lucene',
                                           fl: '*')
      uids = @result['response']['docs'].map { |d| d['uid'] }
      expect(uids).to include('gutenberg:3172')
    end
  end
end
