# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RLetters::Solr::Connection do
  # This is such a vital security requirement that we test it even though
  # it's really an integration test
  #
  # FIXME: This is probably stupid, but I'm keeping it for the moment.
  describe '.search_raw' do
    context 'when fetching external fulltext for a single document' do
      before(:each) do
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
        expect(@result['response']['docs'][0]['uid']).to eq('gutenberg:3172')
      end

      it 'is searchable through fulltext_stem' do
        # PG3172 contains "violated" and "violates" but not "violate"
        @result = described_class.search_raw(q: 'fulltext_stem:violate',
                                             def_type: 'lucene',
                                             fl: '*')
        expect(@result['response']['docs'][0]['uid']).to eq('gutenberg:3172')
      end
    end
  end
end
