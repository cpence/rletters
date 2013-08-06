# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'search/sort_methods', vcr: { cassette_name: 'solr_default' } do

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

  before(:each) do
    # Default to no signed-in user
    view.stub(:current_user) { nil }
    view.stub(:user_signed_in?) { false }

    # No search, just default
    do_solr_query

    render
  end

  it 'shows a link to sort by score' do
    expected = url_for(params.merge({ action: 'index', sort: 'score desc' }))
    rendered.should have_tag("a[href='#{expected}']")
  end

  it 'shows a link to sort ascending by journal' do
    expected = url_for(params.merge({ action: 'index', sort: 'journal_sort asc' }))
    rendered.should have_tag("a[href='#{expected}']")
  end
  
end