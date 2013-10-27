# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SearchController do

  describe '#search_params_to_solr_query' do
    it 'correctly eliminates blank params' do
      params = { q: '', precise: '' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to eq('*:*')
      expect(ret[:defType]).to eq('lucene')
    end

    it 'copies over faceted browsing paramters' do
      params = { q: '*:*', precise: 'true',
                 fq: ['authors_facet:W. Shatner',
                      'journal_facet:Astrobiology'] }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:fq][0]).to eq('authors_facet:W. Shatner')
      expect(ret[:fq][1]).to eq('journal_facet:Astrobiology')
    end

    it 'puts together empty precise search correctly' do
      params = { q: '', precise: 'true' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to eq('*:*')
      expect(ret[:defType]).to eq('lucene')
    end

    it 'copies generic precise search content correctly' do
      params = { q: 'test', precise: 'true' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to eq('test')
    end

    it 'combines the search terms with AND' do
      params = { precise: 'true', volume: '30', number: '5' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to eq('volume:(30) AND number:(5)')
    end

    it 'mixes in verbatim search parameters correctly' do
      params = { precise: 'true', authors: 'W. Shatner',
                 volume: '30', number: '5', pages: '300-301' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('authors:(("W* Shatner"))')
      expect(ret[:q]).to include('volume:(30)')
      expect(ret[:q]).to include('number:(5)')
      expect(ret[:q]).to include('pages:(300-301)')
    end

    it 'handles fuzzy params as verbatim without type set' do
      params = { precise: 'true', journal: 'Astrobiology',
                 title: 'Testing with Spaces', fulltext: 'alien' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('journal:(Astrobiology)')
      expect(ret[:q]).to include('title:(Testing with Spaces)')
      expect(ret[:q]).to include('fulltext_search:(alien)')
    end

    it 'handles fuzzy params with type set to verbatim' do
      params = { precise: 'true', journal: 'Astrobiology',
                 journal_type: 'exact', title: 'Testing with Spaces',
                 title_type: 'exact', fulltext: 'alien',
                 fulltext_type: 'exact' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('journal:(Astrobiology)')
      expect(ret[:q]).to include('title:(Testing with Spaces)')
      expect(ret[:q]).to include('fulltext_search:(alien)')
    end

    it 'handles fuzzy params with type set to fuzzy' do
      params = { precise: 'true', journal: 'Astrobiology',
                 journal_type: 'fuzzy', title: 'Testing with Spaces',
                 title_type: 'fuzzy', fulltext: 'alien',
                 fulltext_type: 'fuzzy' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('journal_stem:(Astrobiology)')
      expect(ret[:q]).to include('title_stem:(Testing with Spaces)')
      expect(ret[:q]).to include('fulltext_stem:(alien)')
    end

    it 'handles multiple authors correctly' do
      params = { precise: 'true', authors: 'W. Shatner, J. Doe' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('authors:(("W* Shatner") AND ("J* Doe"))')
    end

    it 'handles Lucene name forms correctly' do
      params = { precise: 'true', authors: 'Joe John Public' }
      ret = controller.send(:search_params_to_solr_query, params)

      # No need to test all of these, just hit a couple
      expect(ret[:q]).to include('"Joe Public"')
      expect(ret[:q]).to include('"J Public"')
      expect(ret[:q]).to include('"JJ Public"')
      expect(ret[:q]).to include('"J John Public"')
    end

    it 'handles only single year' do
      params = { precise: 'true', year_ranges: '1900' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('year:(1900)')
    end

    it 'handles year range' do
      params = { precise: 'true', year_ranges: '1900 - 1910' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('year:([1900 TO 1910])')
    end

    it 'handles multiple single years' do
      params = { precise: 'true', year_ranges: '1900, 1910' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('year:(1900 OR 1910)')
    end

    it 'handles single years with ranges' do
      params = { precise: 'true', year_ranges: '1900, 1910-1920, 1930' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to include('year:(1900 OR [1910 TO 1920] OR 1930)')
    end

    it 'rejects non-numeric year params' do
      params = { precise: 'true', year_ranges: 'asdf, wut-asf, 1-2-523' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).not_to include('year:(')
    end

    it 'correctly copies dismax search' do
      params = { q: 'test' }
      ret = controller.send(:search_params_to_solr_query, params)
      expect(ret[:q]).to eq('test')
      expect(ret[:defType]).to eq('dismax')
    end
  end

end
