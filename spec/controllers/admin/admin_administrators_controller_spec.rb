require 'rails_helper'

RSpec.describe Admin::AdminAdministratorsController, type: :controller do
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

    it 'includes the admin user' do
      expect(response.body).to include(@administrator.email)
    end
  end

  describe '#edit' do
    before(:example) do
      get :edit, id: @administrator.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has an edit field for the e-mail' do
      expect(response.body).to have_selector('input[name="admin_administrator[email]"]')
    end
  end
end
