# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::DashboardController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in :admin_user, @admin_user
  end

  after(:each) do
    sign_out :admin_user
  end

  describe '#index' do
    before(:each) do
      get :index
    end

    context 'with no connection to Solr' do
      it 'loads successfully' do
        response.should be_success
      end

        it 'includes an error message' do
        response.body.should include('Cannot connect to Solr!')
      end
    end

    context 'with a connection to Solr',
            vcr: { cassette_name: 'solr_admin_dashboard' } do
      it 'loads successfully' do
        response.should be_success
      end

      it 'does not include a Solr error message' do
        response.body.should_not include('Cannot connect to Solr!')
      end

      it 'includes the Solr version' do
        response.body.should include('4.3.1')
      end

      it 'includes the database size' do
        response.body.should include('1042 items')
      end
    end
  end

end
