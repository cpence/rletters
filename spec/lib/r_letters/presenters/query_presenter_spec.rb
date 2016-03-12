require 'rails_helper'

RSpec.describe RLetters::Presenters::QueryPresenter do
  before(:example) do
    @q_query = described_class.new(query: Datasets::Query.new(q: 'testing', def_type: 'dismax'))
    @fq_query = described_class.new(query: Datasets::Query.new(q: 'testing', fq: ['year:[1960 TO 1969]'], def_type: 'lucene'))
  end

  describe '#def_type_string' do
    it 'describes the regular search' do
      expect(@q_query.def_type_string).to eq('Normal search')
    end

    it 'describes the advanced search' do
      expect(@fq_query.def_type_string).to eq('Advanced search')
    end
  end

  describe '#fq_string' do
    it 'uses the facet decorators' do
      expect(@fq_query.fq_string[0]).to eq('Year: 1960–1969')
    end

    it 'blows up on a bad facet' do
      expect {
        described_class.new(query: Datasets::Query.new(q: 'testing', fq: ['purple'])).fq_string
      }.to raise_error(ArgumentError)
    end

    it 'returns nil if there are no facets' do
      expect(@q_query.fq_string).to be_nil
    end
  end
end
