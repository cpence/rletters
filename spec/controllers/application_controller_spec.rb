require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render nothing: true
    end
  end

  describe '#set_locale' do
    context 'with no user' do
      before(:example) do
        sign_out :user

        get :index
      end

      it 'leaves locale at default' do
        expect(I18n.locale).to eq(I18n.default_locale)
      end
    end

    context 'with a user' do
      before(:example) do
        @user = create(:user, language: 'es-MX')
        sign_in @user

        get :index
      end

      it 'sets locale to the stored language' do
        expect(I18n.locale).to eq(:'es-MX')
      end
    end
  end

  describe '#set_timezone' do
    context 'with no user' do
      before(:example) do
        sign_out :user

        get :index
      end

      it 'leaves timezone at default' do
        expect(Time.zone.name).to eq('Eastern Time (US & Canada)')
      end
    end

    context 'with a user' do
      before(:example) do
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
      before(:example) do
        I18n.locale = :en
      end

      it 'renders the file' do
        path = Rails.root.join('config', 'locales', 'article_dates_job',
                               'article_dates_job.en.md')
        expect(controller).to receive(:render_to_string)
          .with(file: path, layout: false)
          .and_return('')
        controller.render_localized_markdown(:article_dates_job)
      end
    end

    context 'with a missing locale' do
      before(:example) do
        I18n.locale = :az
      end

      after(:example) do
        I18n.locale = :en
      end

      it 'falls back to English' do
        path = Rails.root.join('config', 'locales', 'article_dates_job',
                               'article_dates_job.en.md')
        expect(controller).to receive(:render_to_string)
          .with(file: path, layout: false)
          .and_return('')
        controller.render_localized_markdown(:article_dates_job)
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
