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

      it 'sets the number of documents' do
        get :index
        expect(assigns(:database_size)).to be
        expect(assigns(:database_size)).to eq(1042)
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

  describe '#image' do
    context 'with an invalid id' do
      it 'returns a 404' do
        expect {
          get :image, id: '123456789'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a valid id' do
      before(:each) do
        @asset = UploadedAsset.find_by(name: 'splash-low').to_param
        @id = @asset.to_param

        get :image, id: @id
      end

      it 'succeeds' do
        expect(response).to be_success
      end

      it 'returns a reasonable content type' do
        expect(response.content_type).to eq('image/png')
      end

      it 'sends some data' do
        expect(response.body.length).to be > 0
      end
    end
  end

end
