# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'search/sort_methods', vcr: { cassette_name: 'solr_default' } do

  before(:each) do
    # Default to no signed-in user
    allow(view).to receive(:current_user).and_return(nil)
    allow(view).to receive(:user_signed_in?).and_return(false)

    # No search, just default
    do_solr_query

    render
  end

  it 'shows a link to sort by score' do
    expected = url_for(params.merge({ action: 'index', sort: 'score desc' }))
    expect(rendered).to have_tag("a[href='#{expected}']")
  end

  it 'shows a link to sort ascending by journal' do
    expected = url_for(params.merge({ action: 'index', sort: 'journal_sort asc' }))
    expect(rendered).to have_tag("a[href='#{expected}']")
  end

end
