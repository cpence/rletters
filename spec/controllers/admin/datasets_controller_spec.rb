# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::DatasetsController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in :admin_user, @admin_user
    @dataset = FactoryGirl.create(:dataset)
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    it 'loads successfully' do
      response.should be_success
    end

    it 'includes the dataset' do
      response.body.should include(@dataset.name)
    end

    it 'includes the user who created it' do
      response.body.should include(@dataset.user.name)
    end

    it 'includes the number of entries' do
      response.body.should include(@dataset.entries.count.to_s)
    end
  end

end
