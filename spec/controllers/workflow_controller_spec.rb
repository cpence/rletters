# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WorkflowController do

  describe '#index' do
    context 'given Solr results' do
      context 'when logged in' do
        before(:each) do
          @user = FactoryGirl.create(:user)
          sign_in @user

          get :index
        end

        it 'loads successfully' do
          expect(response).to be_success
        end

        it 'renders the dashboard' do
          expect(response).to render_template(:dashboard)
        end

        it 'sets the number of documents' do
          expect(assigns(:database_size)).to be
          expect(assigns(:database_size)).to eq(1043)
        end
      end

      context 'when not logged in' do
        before(:each) do
          get :index
        end

        it 'loads successfully' do
          expect(response).to be_success
        end

        it 'renders the index' do
          expect(response).to render_template(:index)
        end
      end
    end

    context 'when Solr fails' do
      it 'loads successfully' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        get :index

        expect(response).to be_success
      end
    end
  end

  describe 'workflow actions' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user

      @dataset = FactoryGirl.create(:dataset, name: 'Test Dataset', working: true, user: @user)
      @disabled = FactoryGirl.create(:dataset, name: 'Disabled Dataset', disabled: true, user: @user)
    end

    describe '#start' do
      it 'loads successfully' do
        get :start
        expect(response).to be_success
      end
    end

    describe '#destroy' do
      before(:each) do
        @user.workflow_active = true
        @user.workflow_class = 'PlotDates'
        @user.workflow_datasets = [@dataset.to_param].to_json

        @user.save
      end

      it 'resets all the workflow parameters' do
        get :destroy
        @user.reload

        expect(@user.workflow_active).to be_false
        expect(@user.workflow_class).to be_nil
        expect(@user.workflow_datasets).to be_nil
      end
    end

    describe '#activate' do
      context 'with no datasets linked' do
        before(:each) do
          get :activate, class: 'PlotDates'
          @user.reload
        end

        it 'sets the workflow parameters' do
          expect(@user.workflow_active).to be_true
          expect(@user.workflow_class).to eq('PlotDates')
          expect(@user.workflow_datasets).to be_nil
        end
      end

      context 'when asked to link a dataset' do
        before(:each) do
          get :activate, class: 'PlotDates', link_dataset_id: @dataset.to_param
          @user.reload
        end

        it 'sets the right parameters' do
          expect(@user.workflow_active).to be_true
          expect(@user.workflow_class).to eq('PlotDates')
          expect(@user.workflow_datasets).to eq([@dataset.to_param].to_json)
        end

        it 'sends the parameters to the view' do
          expect(assigns(:user_datasets)).to eq([@dataset])
        end
      end

      context 'when asked to unlink a dataset' do
        before(:each) do
          @user.workflow_active = true
          @user.workflow_class = 'PlotDates'
          @user.workflow_datasets = [@dataset.to_param].to_json

          get :activate, class: 'PlotDates', unlink_dataset_id: @dataset.to_param
          @user.reload
        end

        it 'unlinks the dataset' do
          expect(@user.workflow_datasets).to be_nil
        end

        it 'sends the parameters to the view' do
          expect(assigns(:user_datasets)).to be_empty
        end
      end
    end
  end

  describe '#fetch' do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      sign_in @user

      @dataset = FactoryGirl.create(:dataset, user: @user, name: 'Enabled')
      @disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled', disabled: true)
      @other_dataset = FactoryGirl.create(:dataset, user: @user2, name: 'OtherUser')

      @finished_task = FactoryGirl.create(:analysis_task, dataset: @dataset, job_type: 'PlotDates', finished_at: DateTime.now)
      @pending_task = FactoryGirl.create(:analysis_task, dataset: @dataset, job_type: 'PlotDates', finished_at: nil)
      @disabled_task = FactoryGirl.create(:analysis_task, dataset: @disabled, job_type: 'PlotDates', finished_at: DateTime.now)
      @other_task = FactoryGirl.create(:analysis_task, dataset: @other_dataset, job_type: 'PlotDates', finished_at: DateTime.now)

      get :fetch
    end

    it 'assigns the tasks, ignoring inactive datasets' do
      expect(assigns(:tasks)).to match_array([@finished_task, @pending_task])
    end

    it 'assigns the finished tasks' do
      expect(assigns(:finished_tasks)).to eq([@finished_task])
    end

    it 'assigns the pending tasks' do
      expect(assigns(:pending_tasks)).to eq([@pending_task])
    end

    context 'with terminate set' do
      before(:each) do
        get :fetch, terminate: true
      end

      it 'destroys the tasks' do
        expect(AnalysisTask.exists?(@pending_task)).to be_false
      end

      it 'leaves everything else alone' do
        expect(AnalysisTask.exists?(@finished_task)).to be_true
        expect(AnalysisTask.exists?(@disabled_task)).to be_true
        expect(AnalysisTask.exists?(@other_task)).to be_true
      end

      it 'redirects to the workflow index' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash alert' do
        expect(flash[:alert]).to be
      end
    end
  end

  describe '#image' do
    context 'with an invalid id' do
      it 'returns a 404' do
        expect {
          get :image, id: '123456789'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a valid id' do
      before(:each) do
        @asset = UploadedAsset.find_by(name: 'splash-low').to_param
        @id = @asset.to_param

        get :image, id: @id
      end

      it 'succeeds' do
        expect(response).to be_success
      end

      it 'returns a reasonable content type' do
        expect(response.content_type).to eq('image/png')
      end

      it 'sends some data' do
        expect(response.body.length).to be > 0
      end
    end
  end

end
