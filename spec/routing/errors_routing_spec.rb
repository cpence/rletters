# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ErrorsController do
  
  describe 'routing' do
    it 'routes to #not_found' do
      get('/404').should route_to('errors#not_found')
      get('/404.html').should route_to('errors#not_found', :format => 'html')
    end    

    it 'routes to #unprocessable' do
      get('/422').should route_to('errors#unprocessable')
      get('/422.html').should route_to('errors#unprocessable', :format => 'html')
    end    

    it 'routes to #internal_error' do
      get('/500').should route_to('errors#internal_error')
      get('/500.html').should route_to('errors#internal_error', :format => 'html')
    end    
  end
  
end
