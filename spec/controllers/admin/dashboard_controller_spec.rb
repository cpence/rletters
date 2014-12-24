require 'spec_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  # Normally I hate turning this on, but in ActiveAdmin, the view logic *is*
  # defined in the same place where I define the controller.
  render_views

  context 'when no admin user is logged in' do
    describe '#index' do
      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to(new_administrator_session_path)
      end
    end
  end

  context 'when an admin user is logged in' do
    before(:example) do
      @administrator = create(:administrator)
      sign_in :administrator, @administrator

      @user = create(:user)
      sign_in :user, @user

      @dataset = create(:dataset, user: @user)
      @analysis_task = create(:analysis_task, dataset: @dataset)
    end

    after(:example) do
      sign_out :administrator
    end

    describe '#index' do
      context 'with no connection to Solr' do
        before(:example) do
          stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
          get :index
        end

        it 'loads successfully' do
          expect(response).to be_success
        end

        it 'includes an error message' do
          expect(response.body).to include('Cannot connect to Solr!')
        end

        it 'links to the dataset' do
          expect(response.body).to have_selector('a', text: @dataset.name)
        end

        it 'links to the user' do
          expect(response.body).to have_selector('a', text: @user.name)
        end

        it 'links to the analysis task' do
          expect(response.body).to have_selector('a', text: @analysis_task.name)
        end
      end

      context 'with a connection to Solr' do
        before(:example) do
          get :index
        end

        it 'loads successfully' do
          expect(response).to be_success
        end

        it 'does not include a Solr error message' do
          expect(response.body).not_to include('Cannot connect to Solr!')
        end

        it 'includes the Solr version' do
          expect(response.body).to include('4.4.0')
        end

        it 'includes the database size' do
          expect(response.body).to include('1502 items')
        end
      end
    end
  end
end
