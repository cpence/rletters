# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:views' if defined?(SimpleCov)

describe 'search/index' do

  before(:each) do
    # Default to no signed-in user
    view.stub(:current_user) { nil }
    view.stub(:user_signed_in?) { false }
  end

  def do_solr_query(q = nil, fq = nil, precise = false, other_params = {})
    assign(:page, 0)
    assign(:per_page, 10)

    params[:q] = q
    params[:fq] = fq
    params[:precise] = precise
    params.merge!(other_params)

    solr_query = SearchController.new.send(:search_params_to_solr_query, params)
    assign(:solr_q, solr_query[:q])
    assign(:solr_qt, solr_query[:qt])
    assign(:solr_fq, solr_query[:fq])

    assign(:sort, params[:sort] || 'score desc')

    assign(:documents, Document.find_all_by_solr_query(solr_query))
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
        rendered.should have_tag('li', text: '1042 articles in database')
      end

      it 'displays the details of a document' do
        rendered.should have_tag('h3', text: 'Parental and Mating Effort: Is There Necessarily a Trade-Off?')
        rendered.should =~ /Kelly A\. Stiver, Suzanne H\. Alonzo/
        rendered.should have_tag('li', text: /Ethology,\s+Vol\.\s+115,\s+\(2009\),\s+pp\.\s+1101-1126/)
      end

      it 'shows the login prompt' do
        rendered.should have_tag('li[data-theme=e]', text: 'Log in to analyze results!')
      end

      it 'shows a link to the sort page' do
        expected = url_for(params.merge({ controller: 'search',
                                          action: 'sort_methods' }))
        rendered.should have_tag("a[href='#{expected}']")
      end

      it 'shows the advanced search link' do
        rendered.should have_tag('li', text: 'Advanced search')
        rendered.should have_tag("a[href='#{search_advanced_path}']")
      end

      it 'shows author facets' do
        rendered.should have_tag('li', text: 'J. C. Crabbe9') do
          with_tag("a[href='#{search_path(fq: ['authors_facet:"J. C. Crabbe"'])}']")
          with_tag('span.ui-li-count', text: '9')
        end
      end

      it 'shows journal facets' do
        rendered.should have_tag('li', text: 'Ethology594') do
          with_tag("a[href='#{search_path(fq: ['journal_facet:"Ethology"'])}']")
          with_tag('span.ui-li-count', text: '594')
        end
      end

      it 'shows year facets' do
        rendered.should have_tag('li', text: '1990–199994') do
          with_tag("a[href='#{search_path(fq: ['year:[1990 TO 1999]'])}']")
          with_tag('span.ui-li-count', text: '94')
        end
      end
    end

    context 'when logged in', vcr: { cassette_name: 'solr_default' } do
      before(:each) do
        @csl_style = CslStyle.find_by_name('Chicago Manual of Style (Author-Date format)')
        @user = FactoryGirl.create(:user, csl_style_id: @csl_style.id)
        view.stub(:current_user) { @user }
        view.stub(:user_signed_in?) { true }

        render
      end

      it 'uses CSL styles when needed' do
        rendered.should have_tag('li:contains("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. Ethology 114: 1227-1238.")')
      end

      it 'shows the create dataset prompt' do
        rendered.should have_tag('li', text: 'Create dataset from search')
        rendered.should have_tag("a[href='#{new_dataset_path(q: '*:*', qt: 'precise', fq: nil)}']")
      end
    end
  end

  context 'when a search with no results is performed', vcr: { cassette_name: 'search_view_fail' } do
    before(:each) do
      do_solr_query('fail')
      render
    end

    it 'displays that no articles are found' do
      rendered.should =~ /no articles found/
    end

    it 'puts the search text in the search box' do
      rendered.should have_tag('input[value=fail]')
    end

    it "doesn't have any pagination links" do
      rendered.should_not have_tag('p.pagination a')
    end
  end

  context 'when an advanced search is performed', vcr: { cassette_name: 'search_view_year_2009' } do
    before(:each) do
      do_solr_query(nil, nil, true, year: 2009)
      render
    end

    it 'displays the advanced search placeholder in the search box' do
      rendered.should have_tag("input[value='(advanced search)']")
    end
  end

  describe 'year facet parsing', vcr: { cassette_name: 'solr_default' } do
    context 'when parsing 2010-*' do
      before(:each) do
        do_solr_query
        render
      end

      it 'parses this facet correctly' do
        rendered.should have_tag('li', text: '2010 and later160') do
          with_tag("a[href='#{search_path(fq: ['year:[2010 TO *]'])}']")
          with_tag('span.ui-li-count', text: '160')
        end
      end
    end

  #   FIXME
  #   context 'when parsing *-1790' do
  #     before(:each) do
  #       do_solr_query
  #       render
  #     end

  #     it 'parses this facet correctly' do
  #       rendered.should have_tag('li', text: 'Before 18001') do |items|
  #         items[0].should have_tag("a[href='#{search_path(fq: [ 'year:[* TO 1799]' ])}']")
  #         items[0].should have_tag('span.ui-li-count', text: '1')
  #       end
  #     end
  #   end
  end

  context 'when displaying facets',
          vcr: { cassette_name: 'search_view_with_facets' } do
    before(:each) do
      do_solr_query(nil, ['authors_facet:"Amanda M. Koltz"', 'journal_facet:"Ethology"'])
      render
    end

    it 'displays a remove all link' do
      rendered.should have_tag('ul.facetlist li', text: 'Remove All') do
        with_tag("a[href='#{search_path}']")
      end
    end

    it 'displays a specific remove-facet link' do
      rendered.should have_tag('ul.facetlist li', text: 'Authors: Amanda M. Koltz') do
        with_tag("a[href='#{search_path(fq: ['journal_facet:"Ethology"'])}']")
      end
    end
  end

end
