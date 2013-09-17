# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Solr::Facets', vcr: { cassette_name: 'solr_default' } do

  before(:each) do
    @result = Solr::Connection.search({ q: '*:*', defType: 'lucene' })
    @facets = @result.facets
  end

  describe '#for_field' do
    it 'has the right facet hash keys' do
      expect(@facets.for_field(:authors_facet)).to have_at_least(1).facet
      expect(@facets.for_field(:journal_facet)).to have_at_least(1).facet
      expect(@facets.for_field(:year)).to have_at_least(1).facet
    end

    it 'parses authors_facet correctly' do
      f = @facets.for_field(:authors_facet).find { |o| o.value == 'J. C. Crabbe' }
      expect(f).to be
      expect(f.hits).to eq(9)
    end

    it 'does not include authors_facet entries for authors not present' do
      f = @facets.for_field(:authors_facet).find { |o| o.value == 'W. Shatner' }
      expect(f).not_to be
    end

    it 'does not include authors_facet entries for authors with no hits' do
      f = @facets.for_field(:authors_facet).find { |o| o.value == 'No Hits' }
      expect(f).not_to be
    end

    it 'parses journal_facet correctly' do
      f = @facets.for_field(:journal_facet).find { |o| o.value == 'Ethology' }
      expect(f).to be
      expect(f.hits).to eq(594)
    end

    it 'does not include journal_facet entries for journals not present' do
      f = @facets.for_field(:journal_facet).find { |o| o.value == 'Journal of Nothing' }
      expect(f).not_to be
    end

    it 'parses year facet queries correctly' do
      f = @facets.for_field(:year).find { |o| o.value == '[2000 TO 2009]' }
      expect(f).to be
      expect(f.hits).to eq(788)
    end

    it 'does not include year facet queries for non-present years' do
      f = @facets.for_field(:year).find { |o| o.value == '[1940 TO 1949]' }
      expect(f).not_to be
    end
  end

  describe '#sorted_for_field' do
    it 'sorts them appropriately when asked' do
      expect(@facets.sorted_for_field(:year).first.label).to eq('2000–2009')
    end
  end

  describe '#for_query' do
    it 'can pick out facets by query' do
      expect(@facets.for_query('year:[2000 TO 2009]')).to be
      expect(@facets.for_query('authors_facet:"J. C. Crabbe"')).to be
    end
  end
end
