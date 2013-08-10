# -*- encoding : utf-8 -*-
require 'spec_helper'

describe InfoController do

  # N.B.: This is an ApplicationController test, but we have to spec it
  # in a real controller, as its implementation uses url_for().
  describe '#ensure_trailing_slash', vcr: { cassette_name: 'info_query' } do
    it 'adds a trailing slash when there is none' do
      request.env['REQUEST_URI'] = '/info'
      get :index, trailing_slash: false
      expect(response).to redirect_to('/info/')
    end

    it 'does not redirect when there is a trailing slash' do
      get :index, trailing_slash: true
      expect(response).not_to be_redirect
    end
  end

  describe '#index' do
    context 'given Solr results', vcr: { cassette_name: 'info_query' } do
      it 'loads successfully' do
        get :index
        expect(response).to be_success
      end
    end

    context 'when Solr fails', vcr: { cassette_name: 'info_query_error' } do
      it 'loads successfully' do
        get :index
        expect(response).to be_success
      end
    end
  end

  describe '#faq' do
    it 'loads successfully' do
      get :faq
      expect(response).to be_success
    end
  end

  describe '#about' do
    it 'loads successfully' do
      get :about
      expect(response).to be_success
    end
  end

  describe '#privacy' do
    it 'loads successfully' do
      get :privacy
      expect(response).to be_success
    end
  end

  describe '#tutorial' do
    it 'loads successfully' do
      get :tutorial
      expect(response).to be_success
    end
  end

end
