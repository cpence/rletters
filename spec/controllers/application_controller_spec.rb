# -*- encoding : utf-8 -*-
require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      render nothing: true
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
        @user = create(:user, language: 'es-MX')
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
        @user = create(:user, timezone: 'Mexico City')
        sign_in @user

        get :index
      end

      it 'sets timezone to the stored timezone' do
        expect(Time.zone.name).to eq('Mexico City')
      end
    end
  end

  describe '#render_localized_markdown' do
    context 'with a locale that exists' do
      before(:each) do
        I18n.locale = :en
      end

      it 'renders the file' do
        path = Rails.root.join('config', 'locales', 'plot_dates', 'plot_dates.en.md')
        expect(controller).to receive(:render_to_string).with(file: path, layout: false).and_return('')
        controller.render_localized_markdown(:plot_dates)
      end
    end

    context 'with a missing locale' do
      before(:each) do
        I18n.locale = :az
      end

      after(:each) do
        I18n.locale = :en
      end

      it 'falls back to English' do
        path = Rails.root.join('config', 'locales', 'plot_dates', 'plot_dates.en.md')
        expect(controller).to receive(:render_to_string).with(file: path, layout: false).and_return('')
        controller.render_localized_markdown(:plot_dates)
      end
    end

    context 'with a missing file' do
      it 'raises MissingTranslationData' do
        expect {
          controller.render_localized_markdown(:not_there)
        }.to raise_error(I18n::MissingTranslationData)
      end
    end
  end
end
