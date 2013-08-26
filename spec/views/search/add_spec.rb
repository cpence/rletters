# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'search/add', vcr: { cassette_name: 'solr_single' } do

  before(:each) do
    params[:id] = '00972c5123877961056b21aea4177d0dc69c7318'
    @document = Document.find(params[:id])
    assign(:document, @document)
    assign(:datasets, [])

    render
  end

  it 'has a link back to the show page' do
    expect(rendered).to have_tag("a[href='#{search_show_path(id: @document.shasum)}']")
  end

end
