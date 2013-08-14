# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'search/show', vcr: { cassette_name: 'solr_single' } do

  before(:all) do
    Setting.mendeley_key = 'asdf'
  end

  after(:all) do
    Setting.mendeley_key = ''
  end

  before(:each) do
    # Default to no signed-in user
    allow(view).to receive(:current_user).and_return(nil)
    allow(view).to receive(:user_signed_in?).and_return(false)

    params[:id] = '00972c5123877961056b21aea4177d0dc69c7318'
    assign(:document, Document.find(params[:id]))
  end

  context 'when not logged in' do
    before(:each) do
      render template: 'search/show', layout: 'layouts/application'
    end

    it 'shows the document details' do
      expect(rendered).to match(/Document details/)
      expect(rendered).to have_tag('h3', text: 'How Reliable are the Methods for Estimating Repertoire Size?')
    end

    it 'has a link to the DOI' do
      expect(rendered).to have_tag('a[href="http://dx.doi.org/10.1111/j.1439-0310.2008.01576.x"]')
    end

    it 'has a link to Mendeley' do
      expect(rendered).to have_tag("a[href='#{mendeley_redirect_path(id: '00972c5123877961056b21aea4177d0dc69c7318')}']")
    end

    it 'has a link to citeulike' do
      expect(rendered).to have_tag("a[href='#{citeulike_redirect_path(id: '00972c5123877961056b21aea4177d0dc69c7318')}']")
    end

    it 'links to the unAPI server' do
      expect(rendered).to have_tag("link[href='#{unapi_url}'][rel=unapi-server][type='application/xml']")
    end

    it 'sets the unAPI ID' do
      expect(rendered).to have_tag('.unapi-id')
    end

    it 'does not have a link to create a dataset' do
      expect(rendered).not_to match(/Create a dataset from only this document/)
    end
  end

  context 'when logged in' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      allow(view).to receive(:current_user).and_return(@user)
      allow(view).to receive(:user_signed_in?).and_return(true)

      @library = FactoryGirl.create(:library, user: @user)
      @user.libraries.reload

      assign(:user, @user)
      render
    end

    it 'has a link to create a dataset from this document' do
      expected = new_dataset_path(q: 'shasum:00972c5123877961056b21aea4177d0dc69c7318', defType: 'lucene', fq: nil)
      expect(rendered).to have_tag("a[href='#{expected}']")
    end

    it 'has a link to add this document to a dataset' do
      expect(rendered).to have_tag("a[href='#{search_add_path(id: '00972c5123877961056b21aea4177d0dc69c7318')}']")
    end

    it 'has a link to the stored library' do
      expect(rendered).to have_tag("a[href='#{@library.url}ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article&rft_id=info:doi%2F10.1111%2Fj.1439-0310.2008.01576.x&rft.atitle=How+Reliable+are+the+Methods+for+Estimating+Repertoire+Size%3F&rft.title=Ethology&rft.date=2008&rft.volume=114&rft.spage=1227&rft.epage=1238&rft.aufirst=Carlos+A.&rft.aulast=Botero&rft.au=Andrew+E.+Mudge&rft.au=Amanda+M.+Koltz&rft.au=Wesley+M.+Hochachka&rft.au=Sandra+L.+Vehrencamp']")
    end
  end

end
