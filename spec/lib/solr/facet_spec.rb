# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Solr::Facet do

  describe '#initialize' do
    context 'with facet.query but without hits' do
      it 'raises an exception' do
        expect {
          Solr::Facet.new(query: 'year:[1960 TO 1969]')
        }.to raise_error(ArgumentError)
      end
    end

    context 'with malformed facet.query' do
      it 'raises an exception' do
        expect {
          Solr::Facet.new(query: 'asdf', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with facet.query for the wrong field' do
      it 'raises an exception' do
        expect {
          Solr::Facet.new(query: 'authors_facet:"W. Shatner"', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with valid two-parameter form' do
      before(:each) do
        @facet = Solr::Facet.new(query: 'year:[1960 TO 1969]', hits: 10)
      end

      it 'leaves the query alone' do
        @facet.query.should eq('year:[1960 TO 1969]')
      end

      it 'sets the user-friendly label' do
        @facet.label.should eq('1960–1969')
        @facet.field_label.should eq('Year')
      end
    end

    context 'for the strange year values' do
      it 'sets the before value correctly' do
        facet = Solr::Facet.new(query: 'year:[* TO 1800]', hits: 10)
        facet.label.should eq('Before 1800')
      end

      it 'sets the after value correctly' do
        facet = Solr::Facet.new(query: 'year:[2010 TO *]', hits: 10)
        facet.label.should eq('2010 and later')
      end
    end

    context 'with missing name' do
      it 'raises an exception' do
        expect {
          Solr::Facet.new(value: 'W. Shatner', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with missing value' do
      it 'raises an exception' do
        expect {
          Solr::Facet.new(name: 'authors_facet', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with missing hits' do
      it 'raises an exception' do
        expect {
          Solr::Facet.new(name: 'authors_facet', value: 'W. Shatner')
        }.to raise_error(ArgumentError)
      end
    end

    context 'for an unknown field' do
      it 'raises an exception' do
        expect {
          Solr::Facet.new(name: 'zuzax', value: 'W. Shatner', hits: 10)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with valid three-parameter form' do
      before(:each) do
        @facet = Solr::Facet.new(name: 'authors_facet', value: '"W. Shatner"', hits: 10)
      end

      it 'strips quotes from values' do
        @facet.value.should eq('W. Shatner')
      end

      it 'builds the right query' do
        @facet.query.should eq('authors_facet:"W. Shatner"')
      end

      it 'sets the user-friendly labels' do
        @facet.label.should eq('W. Shatner')
        @facet.field_label.should eq('Authors')
      end
    end
  end

  describe '#<=>' do
    context 'for two different-hits facets' do
      it 'sorts them in order by count first' do
        f1 = Solr::Facet.new(name: 'authors_facet', value: '"W. Shatner"', hits: 30)
        f2 = Solr::Facet.new(name: 'authors_facet', value: '"P. Stewart"', hits: 10)

        f1.should be < f2
      end
    end

    context 'for two same-hits facets' do
      it 'sorts authors alphabetically' do
        f1 = Solr::Facet.new(name: 'authors_facet', value: '"W. Shatner"', hits: 10)
        f2 = Solr::Facet.new(name: 'authors_facet', value: '"P. Stewart"', hits: 10)

        f1.should be > f2
      end

      it 'sort years by year, newest first' do
        f1 = Solr::Facet.new(query: 'year:[1850 TO 1860]', hits: 10)
        f2 = Solr::Facet.new(query: 'year:[1950 TO 1960]', hits: 10)

        f2.should be < f1
      end
    end
  end

end
