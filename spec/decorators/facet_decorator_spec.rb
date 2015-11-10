require 'rails_helper'

RSpec.describe FacetDecorator, type: :decorator do
  before(:example) do
    @facets = [
      described_class.decorate(RLetters::Solr::Facet.new(field: 'authors_facet', value: '"W. Shatner"', hits: 10)),
      described_class.decorate(RLetters::Solr::Facet.new(field: 'journal_facet', value: '"The Journal"', hits: 10)),
      described_class.decorate(RLetters::Solr::Facet.new(query: 'year:[1960 TO 1969]', hits: 10))
    ]
  end

  describe '#label' do
    it 'reproduces authors and journals' do
      expect(@facets.take(2).map(&:label)).to eq(['W. Shatner', 'The Journal'])
    end

    it 'creates proper decade labels' do
      expect(@facets[2].label).to eq('1960–1969')
    end

    context 'for the strange year values' do
      it 'sets the before value correctly' do
        facet = RLetters::Solr::Facet.new(query: 'year:[* TO 1800]', hits: 10)
        expect(described_class.decorate(facet).label).to eq('Before 1800')
      end

      it 'sets the after value correctly' do
        facet = RLetters::Solr::Facet.new(query: 'year:[2010 TO *]', hits: 10)
        expect(described_class.decorate(facet).label).to eq('2010 and later')
      end
    end

    it 'throws for invalid fields' do
      facet = double(RLetters::Solr::Facet, field: :space_facet, value: 'Spaceman Spiff', hits: 10)
      expect {
        described_class.decorate(facet).label
      }.to raise_error(ArgumentError)
    end
  end

  describe '#field_label' do
    it 'has labels for all fields' do
      expect(@facets.map(&:field_label)).to eq(%w(Authors Journal Year))
    end

    it 'throws for invalid fields' do
      facet = double(RLetters::Solr::Facet, field: :space_facet, value: 'Spaceman Spiff', hits: 10)
      expect {
        described_class.decorate(facet).field_label
      }.to raise_error(ArgumentError)
    end
  end
end
