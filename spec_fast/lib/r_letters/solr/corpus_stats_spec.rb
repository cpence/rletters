# -*- encoding : utf-8 -*-
require 'r_letters/solr/corpus_stats'

describe RLetters::Solr::CorpusStats do
  before(:each) do
    @stats = described_class.new

    stub_const('Solr', Module.new)
    stub_const('Solr::Connection', Class.new)
    stub_const('Solr::ConnectionError', Class.new)
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
      expect(::Solr::Connection).to receive(:search).with(@query).and_return(@response)
      expect(@stats.size).to eq(1234)
    end
  end
end
