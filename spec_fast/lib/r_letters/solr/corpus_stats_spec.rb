# -*- encoding : utf-8 -*-
require 'r_letters/solr/corpus_stats'

describe RLetters::Solr::CorpusStats do
  before(:each) do
    @stats = described_class.new

    stub_const('RLetters::Solr::Connection', Class.new)
    stub_const('RLetters::Solr::ConnectionError', Class.new)
  end

  describe '#size' do
    before(:each) do
      @response = double(num_hits: 1234)
      @query = {
        q: '*:*',
        def_type: 'lucene',
        rows: 1
      }
    end

    it 'works' do
      expect(RLetters::Solr::Connection).to receive(:search).with(@query).and_return(@response)
      expect(@stats.size).to eq(1234)
    end
  end
end
