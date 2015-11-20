require 'rails_helper'

RSpec.describe RLetters::Solr::Search do
  describe '#params_to_query' do
    context 'for non-API searches' do
      it 'correctly eliminates blank params' do
        params = { q: '', advanced: '' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to eq('*:*')
        expect(ret[:def_type]).to eq('lucene')
      end

      it 'copies over faceted browsing paramters' do
        params = { q: '*:*', advanced: 'true',
                   fq: ['authors_facet:W. Shatner',
                        'journal_facet:Astrobiology'] }
        ret = described_class.params_to_query(params)
        expect(ret[:fq][0]).to eq('authors_facet:W. Shatner')
        expect(ret[:fq][1]).to eq('journal_facet:Astrobiology')
      end

      it 'does the right thing with categories' do
        category = Documents::Category.create(name: 'Test Category', journals: ['Gutenberg', 'PLoS Neglected Tropical Diseases'])
        params = { q: '*:*', advanced: 'true', categories: [category.to_param] }
        ret = described_class.params_to_query(params)
        expect(ret[:fq][0]).to eq('journal_facet:("Gutenberg" OR "PLoS Neglected Tropical Diseases")')
      end

      it 'puts together empty advanced search correctly' do
        params = { q: '', advanced: 'true' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to eq('*:*')
        expect(ret[:def_type]).to eq('lucene')
      end

      it 'copies generic advanced search content correctly' do
        params = { q: 'test', advanced: 'true' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to eq('test')
      end

      it 'combines the search terms with the boolean values' do
        params = { advanced: 'true', field_0: 'volume', value_0: '30',
                   boolean_0: 'and', field_1: 'number', value_1: '5',
                   boolean_1: 'or', field_2: 'pages', value_2: '300-301' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to eq('volume:"30" AND number:"5" OR pages:"300-301"')
      end

      it 'mixes in verbatim search parameters correctly' do
        params = { advanced: 'true', field_0: 'authors', value_0: 'W. Shatner',
                   boolean_0: 'and', field_1: 'volume', value_1: '30',
                   boolean_1: 'and', field_2: 'number', value_2: '5',
                   boolean_2: 'and', field_3: 'pages', value_3: '300-301' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('authors:(("W* Shatner"))')
        expect(ret[:q]).to include('volume:"30"')
        expect(ret[:q]).to include('number:"5"')
        expect(ret[:q]).to include('pages:"300-301"')
      end

      it 'handles fuzzy params with type set to verbatim' do
        params = { advanced: 'true', field_0: 'journal_exact',
                   value_0: 'Astrobiology', boolean_0: 'and',
                   field_1: 'title_exact', value_1: 'Testing with Spaces',
                   boolean_1: 'and', field_2: 'fulltext_exact',
                   value_2: 'alien' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('journal:"Astrobiology"')
        expect(ret[:q]).to include('title:"Testing with Spaces"')
        expect(ret[:q]).to include('fulltext_search:"alien"')
      end

      it 'handles fuzzy params with type set to fuzzy' do
        params = { advanced: 'true', field_0: 'journal_fuzzy',
                   value_0: 'Astrobiology', boolean_0: 'and',
                   field_1: 'title_fuzzy', value_1: 'Testing with Spaces',
                   boolean_1: 'and', field_2: 'fulltext_fuzzy',
                   value_2: 'alien' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('journal_stem:"Astrobiology"')
        expect(ret[:q]).to include('title_stem:"Testing with Spaces"')
        expect(ret[:q]).to include('fulltext_stem:"alien"')
      end

      it 'handles multiple authors correctly' do
        params = { advanced: 'true', field_0: 'authors',
                   value_0: 'W. Shatner, J. Doe' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('authors:(("W* Shatner") AND ("J* Doe"))')
      end

      it 'handles Lucene name forms correctly' do
        params = { advanced: 'true', field_0: 'authors',
                   value_0: 'Joe John Public' }
        ret = described_class.params_to_query(params)

        # No need to test all of these, just hit a couple
        expect(ret[:q]).to include('"Joe Public"')
        expect(ret[:q]).to include('"J Public"')
        expect(ret[:q]).to include('"JJ Public"')
        expect(ret[:q]).to include('"J John Public"')
      end

      it 'handles only single year' do
        params = { advanced: 'true', field_0: 'year_ranges', value_0: '1900' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('year:(1900)')
      end

      it 'handles year range with dash' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: '1900 - 1910' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('year:([1900 TO 1910])')
      end

      it 'handles year range with hyphen' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: '1900-1910' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('year:([1900 TO 1910])')
      end

      it 'handles multiple single years' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: '1900, 1910' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('year:(1900 OR 1910)')
      end

      it 'handles single years with ranges' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: '1900, 1910-1920, 1930' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to include('year:(1900 OR [1910 TO 1920] OR 1930)')
      end

      it 'rejects non-numeric year params' do
        params = { advanced: 'true', field_0: 'year_ranges',
                   value_0: 'asdf, wut-asf, 1-2-523' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).not_to include('year:(')
      end

      it 'correctly copies dismax search' do
        params = { q: 'test' }
        ret = described_class.params_to_query(params)
        expect(ret[:q]).to eq('test')
        expect(ret[:def_type]).to eq('dismax')
      end

      it 'ignores page and per_page' do
        params = { page: '1', per_page: '20' }
        ret = described_class.params_to_query(params)
        expect(ret[:start]).to be_nil
        expect(ret[:rows]).to eq(16)
      end

      it 'sets the initial cursor mark' do
        params = { q: 'test' }
        ret = described_class.params_to_query(params)
        expect(ret[:cursor_mark]).to eq('*')
      end

      it 'copies the non-initial cursor mark' do
        params = { q: 'test', cursor_mark: 'asdf' }
        ret = described_class.params_to_query(params)
        expect(ret[:cursor_mark]).to eq('asdf')
      end

      it 'sorts by year, descending, by default' do
        params = {}
        ret = described_class.params_to_query(params)
        expect(ret[:sort]).to eq('year_sort desc,uid asc')
      end

      it 'sorts by year, descending, with just a facet query' do
        params = { fq: ['journal_facet:"Journal of Nothing"'] }
        ret = described_class.params_to_query(params)
        expect(ret[:sort]).to eq('year_sort desc,uid asc')
      end

      it 'sorts by score, descending, for a basic dismax search' do
        params = { q: 'testing' }
        ret = described_class.params_to_query(params)
        expect(ret[:sort]).to eq('score desc,uid asc')
      end
    end

    context 'for API searches' do
      it 'successfully parses page and per_page parameters parameters' do
        params = { page: '1', per_page: '20' }
        ret = described_class.params_to_query(params, true)
        expect(ret[:start]).to eq(20)
        expect(ret[:rows]).to eq(20)
      end

      it 'clamps non-integral page values' do
        params = { page: 'zzyzzy', per_page: '20' }
        ret = described_class.params_to_query(params, true)
        expect(ret[:start]).to eq(0)
        expect(ret[:rows]).to eq(20)
      end

      it 'clamps non-integral per_page values' do
        params = { page: '1', per_page: 'zzyzzy' }
        ret = described_class.params_to_query(params, true)
        expect(ret[:start]).to eq(10)
        expect(ret[:rows]).to eq(10)
      end

      it 'rounds up zero items per page' do
        params = { page: '1', per_page: '0' }
        ret = described_class.params_to_query(params, true)
        expect(ret[:start]).to eq(10)
        expect(ret[:rows]).to eq(10)
      end

      it 'does not include a cursor mark by default' do
        params = {}
        ret = described_class.params_to_query(params, true)
        expect(ret[:cursor_mark]).to be_nil
      end

      it 'does not include a cursor mark even when passed one' do
        params = { cursor_mark: 'asdf' }
        ret = described_class.params_to_query(params, true)
        expect(ret[:cursor_mark]).to be_nil
      end

      it 'does not include UID in the sort fields' do
        params = {}
        ret = described_class.params_to_query(params, true)
        expect(ret[:sort]).to eq('year_sort desc')
      end
    end
  end
end
