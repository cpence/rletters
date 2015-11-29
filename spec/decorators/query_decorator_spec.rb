require 'rails_helper'

RSpec.describe QueryDecorator, type: :decorator do
  before(:example) do
    @q_query = described_class.decorate(Datasets::Query.new(q: 'testing', def_type: 'dismax'))
    @fq_query = described_class.decorate(Datasets::Query.new(q: 'testing', fq: ['year:[1960 TO 1969]'], def_type: 'lucene'))
  end

  describe '#def_type' do
    it 'describes the regular search' do
      expect(@q_query.def_type).to eq('Normal search')
    end

    it 'describes the advanced search' do
      expect(@fq_query.def_type).to eq('Advanced search')
    end
  end

  describe '#fq' do
    it 'uses the facet decorators' do
      expect(@fq_query.fq[0]).to eq('Year: 1960–1969')
    end

    it 'blows up on a bad facet' do
      expect {
        described_class.decorate(Datasets::Query.new(q: 'testing', fq: ['purple'])).fq
      }.to raise_error(ArgumentError)
    end

    it 'returns nil if there are no facets' do
      expect(@q_query.fq).to be_nil
    end
  end
end
