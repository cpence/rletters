# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::AdminUsersController do
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
      expect(response).to be_success
    end

    it 'includes the admin user' do
      expect(response.body).to include(@admin_user.email)
    end
  end

  describe '#edit' do
    before(:each) do
      get :edit, id: @admin_user.to_param
    end

    it 'loads successfully' do
      expect(response).to be_success
    end

    it 'has an edit field for the e-mail' do
      expect(response.body).to have_tag('input[name="admin_user[email]"]')
    end
  end

end
