# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render nothing: true
    end
  end

  describe '#ensure_trailing_slash' do
    it 'adds a trailing slash when there is none' do
      # This relies on an implementation detail of anonymous controllers in
      # RSpec, but I doubt it will change any time soon.
      path_spec = { 'controller' => 'anonymous',
                    'action' => 'index',
                    'trailing_slash' => true }
      allow(controller).to receive(:url_for).with(path_spec).and_return('http://test.host/anonymous/')

      request.env['REQUEST_URI'] = '/anonymous'
      get :index, trailing_slash: false
      expect(response).to redirect_to('/anonymous/')
    end

    it 'does not redirect when there is a trailing slash' do
      get :index, trailing_slash: true
      expect(response).not_to be_redirect
    end
  end

  describe '#set_locale' do
    context 'with no user' do
      before(:each) do
        sign_out :user

        get :index
      end

      it 'leaves locale at default' do
        expect(I18n.locale).to eq(I18n.default_locale)
      end
    end

    context 'with a user' do
      before(:each) do
        @user = FactoryGirl.create(:user, language: 'es-MX')
        sign_in @user

        get :index
      end

      it 'sets locale to the stored language' do
        expect(I18n.locale).to eq(:'es-MX') # rubocop:disable SymbolName
      end
    end
  end

  describe '#set_timezone' do
    context 'with no user' do
      before(:each) do
        sign_out :user

        get :index
      end

      it 'leaves timezone at default' do
        expect(Time.zone.name).to eq('Eastern Time (US & Canada)')
      end
    end

    context 'with a user' do
      before(:each) do
        @user = FactoryGirl.create(:user, timezone: 'Mexico City')
        sign_in @user

        get :index
      end

      it 'sets timezone to the stored timezone' do
        expect(Time.zone.name).to eq('Mexico City')
      end
    end
  end
end
