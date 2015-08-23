require 'rails_helper'

RSpec.describe Admin::AdminSettingsController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:example) do
    @administrator = create(:administrator)
    sign_in :administrator, @administrator
  end

  describe '#index' do
    before(:example) do
      get :index
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'includes all of the visible settings' do
      shown_keys = Admin::Setting.valid_keys - Admin::Setting.hidden_keys
      shown_keys.each do |k|
        expect(response.body).to include(I18n.t("settings.#{k}"))
      end
    end

    it 'does not include hidden settings' do
      Admin::Setting.hidden_keys.each do |k|
        expect(response.body).to_not include(I18n.t("settings.#{k}"))
      end
    end

    it 'includes all of the default values' do
      Admin::Setting.valid_keys.each do |k|
        method = "default_#{k}".to_sym
        next unless Admin::Setting.respond_to? method

        default = Admin::Setting.send(method)
        next unless default

        expect(response.body).to include(default.to_s)
      end
    end
  end

  describe '#edit' do
    before(:example) do
      @setting = Admin::Setting.where(key: :app_name).first_or_create(value: Admin::Setting.send(:app_name))
      get :edit, id: @setting.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has a textarea field for the value' do
      expect(response.body).to have_selector('textarea[name="admin_setting[value]"]')
    end
  end
end
