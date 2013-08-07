# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::SettingsController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in :admin_user, @admin_user
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'loads successfully' do
      response.should be_success
    end

    it 'includes all of the settings' do
      Setting.valid_keys.each do |k|
        response.body.should include(I18n.t("settings.#{k}"))
      end
    end

    it 'includes all of the default values' do
      Setting.valid_keys.each do |k|
        method = "default_#{k}".to_sym
        next unless Setting.respond_to? method

        default = Setting.send(method)
        next unless default

        response.body.should include(default.to_s)
      end
    end
  end

end
