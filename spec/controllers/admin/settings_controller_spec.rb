# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::SettingsController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @administrator = FactoryGirl.create(:administrator)
    sign_in :administrator, @administrator
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes all of the settings' do
      Setting.valid_keys.each do |k|
        expect(response.body).to include(I18n.t("settings.#{k}"))
      end
    end

    it 'includes all of the default values' do
      Setting.valid_keys.each do |k|
        method = "default_#{k}".to_sym
        next unless Setting.respond_to? method

        default = Setting.send(method)
        next unless default

        expect(response.body).to include(default.to_s)
      end
    end
  end

  describe '#edit' do
    before(:each) do
      @setting = Setting.where(key: :app_name).first_or_create(value: Setting.send(:app_name))
      get :edit, id: @setting.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has a textarea field for the value' do
      expect(response.body).to have_selector('textarea[name="setting[value]"]')
    end
  end

end
