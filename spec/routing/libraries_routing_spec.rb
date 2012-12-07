# -*- encoding : utf-8 -*-
require 'spec_helper'

describe LibrariesController do
  
  describe "routing" do
    it 'routes to #index' do
      get('/users/libraries').should route_to('libraries#index')
    end
    
    it 'routes to #new' do
      get('/users/libraries/new').should route_to('libraries#new')
    end
    
    it 'routes to #edit' do
      get('/users/libraries/1/edit').should route_to('libraries#edit', :id => "1")
    end
    
    it 'routes to #delete' do
      get('/users/libraries/1/delete').should route_to('libraries#delete', :id => "1")
    end
    
    it 'routes to #create' do
      post('/users/libraries').should route_to('libraries#create')
    end
    
    it 'routes to #update' do
      put('/users/libraries/1').should route_to('libraries#update', :id => "1")
    end
    
    it 'routes to #destroy' do
      delete('/users/libraries/1').should route_to('libraries#destroy', :id => "1")
    end
    
    it 'routes to #query' do
      get('/users/libraries/query').should route_to('libraries#query')
    end
  end

end
