# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::CslStylesController do
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

    it 'includes some standard CSL styles' do
      response.body.should include('American Sociological Association')
      response.body.should include('Harvard Reference format 1 (Author-Date)')
    end
  end

end
