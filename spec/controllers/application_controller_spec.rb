# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ApplicationController do

  describe '#set_locale' do
    controller(ApplicationController) do
      def index
        render nothing: true
      end
    end

    context 'with no user' do
      before(:each) do
        sign_out :user

        get :index
      end

      it 'leaves locale at default' do
        I18n.locale.should eq(I18n.default_locale)
      end
    end

    context 'with a user' do
      before(:each) do
        @user = FactoryGirl.create(:user, language: 'es-MX')
        sign_in @user

        get :index
      end

      it "sets locale to the user's language" do
        I18n.locale.should eq(:'es-MX') # rubocop:disable SymbolName
      end
    end
  end

  describe '#set_timezone' do
    controller(ApplicationController) do
      def index
        render nothing: true
      end
    end

    context 'with no user' do
      before(:each) do
        sign_out :user

        get :index
      end

      it 'leaves timezone at default' do
        Time.zone.name.should eq('Eastern Time (US & Canada)')
      end
    end

    context 'with a user' do
      before(:each) do
        @user = FactoryGirl.create(:user, timezone: 'Mexico City')
        sign_in @user

        get :index
      end

      it "sets timezone to the user's timezone" do
        Time.zone.name.should eq('Mexico City')
      end
    end
  end
end
