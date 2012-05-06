# -*- encoding : utf-8 -*-
require 'spec_helper'

describe LibrariesController do
  
  login_user
  
  before(:each) do
    @library = FactoryGirl.create(:library, :user => @user)
  end
  
  describe '#index' do
    it 'loads successfully' do
      get :index
      response.should be_success
    end    
  end
  
  describe '#new' do
    it 'loads successfully' do
      get :new
      response.should be_success
    end
  end
  
  describe '#create' do
    context 'when library is valid' do
      it 'creates a library' do
        expect {
          post :create, :library => FactoryGirl.attributes_for(:library, :user => @user)
        }.to change{@user.libraries.count}.by(1)
      end
      
      it 'redirects to the user page' do
        post :create, :library => FactoryGirl.attributes_for(:library, :user => @user)
        response.should redirect_to(user_path)
      end
    end
    
    context 'when library is invalid' do
      it "doesn't create a library" do
        expect {
          post :create, :library => FactoryGirl.attributes_for(:library, :url => 'not##::aurl.asdfwut', :user => @user)
        }.to_not change{@user.libraries.count}
      end
      
      it "renders the new form" do
        post :create, :library => FactoryGirl.attributes_for(:library, :url => 'not##::aurl.asdfwut', :user => @user)
        response.should_not redirect_to(user_path)
      end
    end
  end
  
  describe '#edit' do
    it 'loads successfully' do
      get :edit, :id => @library.to_param
      response.should be_success
    end
  end
  
  describe '#update' do
    context 'when library is valid' do
      it 'edits the library' do
        put :update, :id => @library.to_param, :library => @library.attributes.merge({ :name => 'Woo' })
        @library.reload
        @library.name.should eq('Woo')
      end
      
      it 'redirects to the user page' do
        put :update, :id => @library.to_param, :library => @library.attributes
        response.should redirect_to(user_path)
      end
    end
    
    context 'when library is invalid' do
      it "doesn't edit the library" do
        put :update, :id => @library.to_param, :library => @library.attributes.merge({ :url => '1234%%#$' })

        @library.reload
        @library.url.should_not eq('1234%%#$')
      end
      
      it 'renders the edit form' do
        put :update, :id => @library.to_param, :library => @library.attributes.merge({ :url => '1234%%#$' })
        response.should_not redirect_to(user_path)
      end
    end
  end
  
  describe '#delete' do
    it 'loads successfully' do
      get :delete, :id => @library.to_param
      response.should be_success
    end
  end
  
  describe '#destroy' do
    context 'when cancel is pressed' do
      it 'does not delete the library' do
        expect {
          delete :destroy, :id => @library.to_param, :cancel => true
        }.to_not change{@user.libraries.count}
      end
      
      it 'redirects to the user page' do
        delete :destroy, :id => @library.to_param, :cancel => true
        response.should redirect_to(user_path)
      end
    end
    
    context 'when cancel is not pressed' do
      it 'deletes the library' do
        expect {
          delete :destroy, :id => @library.to_param
        }.to change{@user.libraries.count}.by(-1)
      end
      
      it 'redirects to the user page' do
        delete :destroy, :id => @library.to_param, :cancel => true
        response.should redirect_to(user_path)
      end
    end
  end
  
  describe '#query' do
    context 'when no libraries are returned' do
      it 'assigns no libraries' do
        stub_request(:any, /worldcatlibraries.org\/registry\/lookup.*/).to_return(File.new(Rails.root.join('spec', 'support', 'webmock', 'worldcat_response_empty.txt')))
        get :query
        assigns(:libraries).should have(0).items
      end
    end
    
    context 'when libraries are returned' do
      it 'assigns the libraries' do
        stub_request(:any, /worldcatlibraries.org\/registry\/lookup.*/).to_return(File.new(Rails.root.join('spec', 'support', 'webmock', 'worldcat_response_nd.txt')))
        get :query
        assigns(:libraries).should have(1).item
      end
    end
    
    context 'when WorldCat times out' do
      it 'assigns no libraries' do
        stub_request(:any, /worldcatlibraries.org\/registry\/lookup.*/).to_timeout
        get :query
        assigns(:libraries).should have(0).items
      end
    end
  end

end
