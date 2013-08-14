# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:views' if defined?(SimpleCov)

describe 'search/index' do

  before(:each) do
    # Default to no signed-in user
    allow(view).to receive(:current_user).and_return(nil)
    allow(view).to receive(:user_signed_in?).and_return(false)
  end

  context 'when no search is performed',
          vcr: { cassette_name: 'solr_default' } do
    before(:each) do
      do_solr_query
    end

    context 'when not logged in' do
      before(:each) do
        render
      end

      it 'displays the number of documents in the database' do
        expect(rendered).to have_tag('li', text: '1042 articles in database')
      end

      it 'displays the details of a document' do
        expect(rendered).to have_tag('h3', text: 'Fine mapping of a sedative-hypnotic drug withdrawal locus on mouse chromosome 11')
        expect(rendered).to match(/H\. M\. Hood, P\. Metten, J\. C\. Crabbe, K\. J\. Buck/)
        expect(rendered).to have_tag('li', text: /Genes, Brain and Behavior,\s+Vol\.\s+5,\s+\(2006\),\s+pp\.\s+1-10/)
      end

      it 'shows the login prompt' do
        expect(rendered).to have_tag('li[data-theme=e]', text: 'Log in to analyze results!')
      end

      it 'shows a link to the sort page' do
        expected = url_for(params.merge({ controller: 'search',
                                          action: 'sort_methods' }))
        expect(rendered).to have_tag("a[href='#{expected}']")
      end

      it 'shows the advanced search link' do
        expect(rendered).to have_tag('li', text: 'Advanced search')
        expect(rendered).to have_tag("a[href='#{search_advanced_path}']")
      end

      it 'shows author facets' do
        expect(rendered).to have_tag('li', text: 'J. C. Crabbe9') do
          with_tag("a[href='#{search_path(fq: ['authors_facet:"J. C. Crabbe"'])}']")
          with_tag('span.ui-li-count', text: '9')
        end
      end

      it 'shows journal facets' do
        expect(rendered).to have_tag('li', text: 'Ethology594') do
          with_tag("a[href='#{search_path(fq: ['journal_facet:"Ethology"'])}']")
          with_tag('span.ui-li-count', text: '594')
        end
      end

      it 'shows year facets' do
        expect(rendered).to have_tag('li', text: '1990–199994') do
          with_tag("a[href='#{search_path(fq: ['year:[1990 TO 1999]'])}']")
          with_tag('span.ui-li-count', text: '94')
        end
      end
    end

    context 'when logged in', vcr: { cassette_name: 'solr_default' } do
      before(:each) do
        @csl_style = CslStyle.find_by!(name: 'Chicago Manual of Style (Author-Date format)')
        @user = FactoryGirl.create(:user, csl_style_id: @csl_style.id)
        allow(view).to receive(:current_user).and_return(@user)
        allow(view).to receive(:user_signed_in?).and_return(true)

        render
      end

      it 'uses CSL styles when needed' do
        expect(rendered).to have_tag('li:contains("Komdeur, Jan. 2006. “Variation in Individual Investment Strategies among Social Animals”. Ethology 112: 729-747.")')
      end

      it 'shows the create dataset prompt' do
        expect(rendered).to have_tag('li', text: 'Create dataset from search')
        expect(rendered).to have_tag("a[href='#{new_dataset_path(q: '*:*', defType: 'lucene', fq: nil)}']")
      end
    end
  end

  context 'when a search with no results is performed', vcr: { cassette_name: 'search_view_fail' } do
    before(:each) do
      do_solr_query('fail')
      render
    end

    it 'displays that no articles are found' do
      expect(rendered).to match(/no articles found/)
    end

    it 'puts the search text in the search box' do
      expect(rendered).to have_tag('input[value=fail]')
    end

    it 'does not have any pagination links' do
      expect(rendered).not_to have_tag('p.pagination a')
    end
  end

  context 'when an advanced search is performed', vcr: { cassette_name: 'search_view_year_2009' } do
    before(:each) do
      do_solr_query(nil, nil, true, year: 2009)
      render
    end

    it 'displays the advanced search placeholder in the search box' do
      expect(rendered).to have_tag("input[value='(advanced search)']")
    end
  end

  describe 'year facet parsing', vcr: { cassette_name: 'solr_default' } do
    context 'when parsing 2010-*' do
      before(:each) do
        do_solr_query
        render
      end

      it 'parses this facet correctly' do
        expect(rendered).to have_tag('li', text: '2010 and later160') do
          with_tag("a[href='#{search_path(fq: ['year:[2010 TO *]'])}']")
          with_tag('span.ui-li-count', text: '160')
        end
      end
    end
  end

  context 'when displaying facets',
          vcr: { cassette_name: 'search_view_with_facets' } do
    before(:each) do
      do_solr_query(nil, ['authors_facet:"Amanda M. Koltz"', 'journal_facet:"Ethology"'])
      render
    end

    it 'displays a remove all link' do
      expect(rendered).to have_tag('ul.facetlist li', text: 'Remove All') do
        with_tag("a[href='#{search_path}']")
      end
    end

    it 'displays a specific remove-facet link' do
      expect(rendered).to have_tag('ul.facetlist li', text: 'Authors: Amanda M. Koltz') do
        with_tag("a[href='#{search_path(fq: ['journal_facet:"Ethology"'])}']")
      end
    end
  end

end
