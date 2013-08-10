# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Admin::DashboardController do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  before(:each) do
    @admin_user = FactoryGirl.create(:admin_user)
    sign_in :admin_user, @admin_user

    @user = FactoryGirl.create(:user)
    sign_in :user, @user

    @dataset = FactoryGirl.create(:dataset, user: @user)
    @analysis_task = FactoryGirl.create(:analysis_task, dataset: @dataset)
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
        expect(response).to be_success
      end

      it 'includes an error message' do
        expect(response.body).to include('Cannot connect to Solr!')
      end

      it 'links to the dataset' do
        expect(response.body).to have_tag('a', text: @dataset.name)
      end

      it 'links to the user' do
        expect(response.body).to have_tag('a', text: @user.name)
      end

      it 'links to the analysis task' do
        expect(response.body).to have_tag('a', text: @analysis_task.name)
      end
    end

    context 'with a connection to Solr',
            vcr: { cassette_name: 'solr_admin_dashboard' } do
      it 'loads successfully' do
        expect(response).to be_success
      end

      it 'does not include a Solr error message' do
        expect(response.body).not_to include('Cannot connect to Solr!')
      end

      it 'includes the Solr version' do
        expect(response.body).to include('4.3.1')
      end

      it 'includes the database size' do
        expect(response.body).to include('1042 items')
      end
    end
  end

end
