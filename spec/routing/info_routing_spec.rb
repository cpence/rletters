# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:routing' if defined?(SimpleCov)

describe InfoController do
  
  describe "routing" do
    it 'routes to #index' do
      get('/info').should route_to('info#index')
    end
    
    # This is an important, externally facing URL that's referenced in the
    # docs.  Do not change this test without thinking very carefully!
    it 'routes to #privacy' do
      get('/info/privacy').should route_to('info#privacy')
    end
    
    it 'routes to #faq' do
      get('/info/faq').should route_to('info#faq')
    end
    
    it 'routes to #about' do
      get('/info/about').should route_to('info#about')
    end
    
    it 'routes to #tutorial' do
      get('/info/tutorial').should route_to('info#tutorial')
    end
  end
  
end
