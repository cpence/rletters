# -*- encoding : utf-8 -*-
require 'r_letters/solr/facet'

describe RLetters::Solr::Facet do
  describe '#initialize' do
    context 'with facet.query but without hits' do
      it 'raises an exception' do
        expect {
          described_class.new(query: 'year:[1960 TO 1969]')
        }.to raise_error(ArgumentError)
      end
    end

    context 'with malformed facet.query' do
      it 'raises an exception' do
        expect {
          described_class.new(query: 'asdf', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with facet.query for the wrong field' do
      it 'raises an exception' do
        expect {
          described_class.new(query: 'authors_facet:"W. Shatner"', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with valid two-parameter form' do
      before(:each) do
        @facet = described_class.new(query: 'year:[1960 TO 1969]', hits: 10)
      end

      it 'leaves the query alone' do
        expect(@facet.query).to eq('year:[1960 TO 1969]')
      end
    end

    context 'with missing name' do
      it 'raises an exception' do
        expect {
          described_class.new(value: 'W. Shatner', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with missing value' do
      it 'raises an exception' do
        expect {
          described_class.new(name: 'authors_facet', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with missing hits' do
      it 'raises an exception' do
        expect {
          described_class.new(name: 'authors_facet', value: 'W. Shatner')
        }.to raise_error(ArgumentError)
      end
    end

    context 'for an unknown field' do
      it 'raises an exception' do
        expect {
          described_class.new(name: 'zuzax', value: 'W. Shatner', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with valid three-parameter form' do
      before(:each) do
        @facet = described_class.new(name: 'authors_facet',
                                     value: '"W. Shatner"',
                                     hits: 10)
      end

      it 'strips quotes from values' do
        expect(@facet.value).to eq('W. Shatner')
      end

      it 'builds the right query' do
        expect(@facet.query).to eq('authors_facet:"W. Shatner"')
      end
    end
  end

  describe '#<=>' do
    context 'for two different-hits facets' do
      it 'sorts them in order by count first' do
        f1 = described_class.new(name: 'authors_facet', value: '"W. Shatner"', hits: 30)
        f2 = described_class.new(name: 'authors_facet', value: '"P. Stewart"', hits: 10)

        expect(f1).to be < f2
      end
    end

    context 'for two same-hits facets' do
      it 'sorts authors alphabetically' do
        f1 = described_class.new(name: 'authors_facet', value: '"W. Shatner"', hits: 10)
        f2 = described_class.new(name: 'authors_facet', value: '"P. Stewart"', hits: 10)

        expect(f1).to be > f2
      end

      it 'sort years by year, newest first' do
        f1 = described_class.new(query: 'year:[1850 TO 1860]', hits: 10)
        f2 = described_class.new(query: 'year:[1950 TO 1960]', hits: 10)

        expect(f2).to be < f1
      end
    end
  end
end
