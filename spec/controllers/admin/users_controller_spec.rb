# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::UsersController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in :admin_user, @admin_user
    @user = FactoryGirl.create(:user)
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'loads successfully' do
      response.should be_success
    end

    it 'includes the user' do
      response.body.should include(@user.email)
      response.body.should include(@user.name)
    end
  end

end
