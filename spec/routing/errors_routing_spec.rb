# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ErrorsController do

  describe 'routing' do
    it 'routes to #not_found' do
      expect(get('/404')).to route_to('errors#not_found')
      expect(get('/404.html')).to route_to('errors#not_found', format: 'html')
    end

    it 'routes to #unprocessable' do
      expect(get('/422')).to route_to('errors#unprocessable')
      expect(get('/422.html')).to route_to('errors#unprocessable', format: 'html')
    end

    it 'routes to #internal_error' do
      expect(get('/500')).to route_to('errors#internal_error')
      expect(get('/500.html')).to route_to('errors#internal_error', format: 'html')
    end
  end

end
