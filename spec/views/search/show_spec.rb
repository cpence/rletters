# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "search/show" do
  
  before(:all) do
    APP_CONFIG['mendeley_key'] = 'asdf'
  end
  
  after(:all) do
    APP_CONFIG['mendeley_key'] = ''
  end
  
  before(:each) do
    params[:id] = '00972c5123877961056b21aea4177d0dc69c7318'
    assign(:document, Document.find(params[:id]))
  end
  
  context 'when not logged in' do
    before(:each) do
      render :template => "search/show", :layout => "layouts/application"
    end
    
    it 'shows the document details' do
      rendered.should contain('Document details')
      rendered.should have_selector('h3', :content => 'How Reliable are the Methods for Estimating Repertoire Size?')
    end
    
    it 'has a link to the DOI' do
      rendered.should have_selector("a[href='http://dx.doi.org/10.1111/j.1439-0310.2008.01576.x']")
    end
    
    it 'has a link to Mendeley' do
      rendered.should have_selector("a[href='#{mendeley_redirect_path(:id => '00972c5123877961056b21aea4177d0dc69c7318')}']")
    end
    
    it 'has a link to citeulike' do
      rendered.should have_selector("a[href='#{citeulike_redirect_path(:id => '00972c5123877961056b21aea4177d0dc69c7318')}']")
    end
    
    it 'links to the unAPI server' do
      rendered.should have_selector("link[href='#{unapi_url}'][rel=unapi-server][type='application/xml']")
    end
    
    it 'sets the unAPI ID' do
      rendered.should have_selector(".unapi-id")
    end
    
    it "doesn't have a link to create a dataset" do
      rendered.should_not contain("Create a dataset from only this document")
    end
  end
  
  context 'when logged in' do
    login_user
    
    before(:each) do
      @library = FactoryGirl.create(:library, :user => @user)
      @user.libraries.reload
      
      assign(:user, @user)
      render
    end
    
    it "has a link to create a dataset from this document" do
      expected = new_dataset_path(:q => "shasum:00972c5123877961056b21aea4177d0dc69c7318", :qt => 'precise', :fq => nil)
      rendered.should have_selector("a[href='#{expected}']")
    end

    it 'has a link to add this document to a dataset' do
      rendered.should have_selector("a[href='#{search_add_path(:id => '00972c5123877961056b21aea4177d0dc69c7318')}']")
    end
    
    it "has a link to the user's local library" do
      rendered.should have_selector("a[href='#{@library.url}ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Ajournal&rft.genre=article&rft_id=info:doi%2F10.1111%2Fj.1439-0310.2008.01576.x&rft.atitle=How+Reliable+are+the+Methods+for+Estimating+Repertoire+Size%3F&rft.title=Ethology&rft.date=2008&rft.volume=114&rft.spage=1227&rft.epage=1238&rft.aufirst=Carlos+A.&rft.aulast=Botero&rft.au=Andrew+E.+Mudge&rft.au=Amanda+M.+Koltz&rft.au=Wesley+M.+Hochachka&rft.au=Sandra+L.+Vehrencamp']")
    end
  end
  
end
