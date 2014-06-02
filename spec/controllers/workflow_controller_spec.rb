# -*- encoding : utf-8 -*-
require 'spec_helper'

module Jobs
  module Analysis
    class WorkflowJob < Jobs::Analysis::Base
      include Resque::Plugins::Status
      def perform; end
    end
  end
end

describe WorkflowController do

  describe '#index' do
    context 'given Solr results' do
      context 'when logged in' do
        before(:each) do
          @user = create(:user)
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
      @user = create(:user)
      sign_in @user

      @dataset = create(:dataset, name: 'Test Dataset', working: true,
                                  user: @user)
      @disabled = create(:dataset, name: 'Disabled Dataset', disabled: true,
                                   user: @user)
    end

    describe '#info' do
      it 'loads successfully' do
        get :info, class: 'ArticleDates'
        expect(response).to be_success
      end
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
        @user.workflow_class = 'ArticleDates'
        @user.workflow_datasets = [@dataset]

        @user.save
      end

      it 'resets all the workflow parameters' do
        get :destroy
        @user.reload

        expect(@user.workflow_active).to be false
        expect(@user.workflow_class).to be_nil
        expect(@user.workflow_datasets).to be_blank
      end
    end

    describe '#activate' do
      context 'with no datasets linked' do
        before(:each) do
          get :activate, class: 'ArticleDates'
          @user.reload
        end

        it 'sets the workflow parameters' do
          expect(@user.workflow_active).to be true
          expect(@user.workflow_class).to eq('ArticleDates')
          expect(@user.workflow_datasets).to be_blank
        end
      end

      context 'when asked to link a dataset' do
        before(:each) do
          get :activate, class: 'ArticleDates', link_dataset_id: @dataset.to_param
          @user.reload
        end

        it 'sets the right parameters' do
          expect(@user.workflow_active).to be true
          expect(@user.workflow_class).to eq('ArticleDates')
          expect(@user.workflow_datasets).to eq([@dataset])
        end
      end

      context 'when asked to unlink a dataset with one dataset' do
        before(:each) do
          @user.workflow_active = true
          @user.workflow_class = 'ArticleDates'
          @user.workflow_datasets = [@dataset]
          @user.save

          get :activate, class: 'ArticleDates', unlink_dataset_id: @dataset.to_param
          @user.reload
        end

        it 'unlinks the dataset' do
          expect(@user.workflow_datasets).to be_blank
        end
      end

      context 'when asked to unlink a dataset with multiple datasets' do
        before(:each) do
          @dataset_2 = create(:dataset, user: @user)

          @user.workflow_active = true
          @user.workflow_class = 'CraigZeta'
          @user.workflow_datasets = [@dataset, @dataset_2]
          @user.save

          get :activate, class: 'CraigZeta', unlink_dataset_id: @dataset_2.to_param
          @user.reload
        end

        it 'unlinks the dataset' do
          expect(@user.workflow_datasets).to eq([@dataset])
        end
      end
    end
  end

  describe '#fetch' do
    def make_task(dataset, finished)
      task = create(:analysis_task, dataset: dataset, finished_at: finished,
                                    job_type: 'WorkflowJob')

      uuid = Jobs::Analysis::WorkflowJob.create(
        user_id: dataset.user.to_param,
        dataset_id: dataset.to_param,
        task_id: task.to_param
      )

      task.reload
      task.resque_key = uuid
      task.save

      task
    end

    before(:each) do
      @user = create(:user)
      @user2 = create(:user)
      sign_in @user

      @dataset = create(:dataset, user: @user, name: 'Enabled')
      @disabled = create(:dataset, user: @user, name: 'Disabled',
                                   disabled: true)
      @other_dataset = create(:dataset, user: @user2, name: 'OtherUser')

      @finished_task = make_task(@dataset, DateTime.now)
      @pending_task = make_task(@dataset, nil)

      @working_task = make_task(@dataset, nil)
      @uuid = @working_task.resque_key
      Resque::Plugins::Status::Hash.set(@uuid,
        Resque::Plugins::Status::Hash.get(@uuid),
        { 'status' => 'working',
          'name' => 'WorkflowJob' })

      @disabled_task = make_task(@disabled, DateTime.now)
      @other_task = make_task(@other_dataset, DateTime.now)

      get :fetch
    end

    it 'assigns the finished tasks' do
      expect(assigns(:finished_tasks).to_a).to eq([@finished_task])
    end

    it 'assigns the pending tasks' do
      expect(assigns(:pending_tasks).to_a).to match_array(
        [@pending_task,
         @working_task])
    end

    context 'with terminate set' do
      before(:each) do
        @uuid = @working_task.resque_key
        get :fetch, terminate: true
      end

      it 'destroys the tasks' do
        expect(Datasets::AnalysisTask.exists?(@pending_task)).to be false
        expect(Datasets::AnalysisTask.exists?(@working_task)).to be false
      end

      it 'leaves everything else alone' do
        expect(Datasets::AnalysisTask.exists?(@finished_task)).to be true
        expect(Datasets::AnalysisTask.exists?(@disabled_task)).to be true
        expect(Datasets::AnalysisTask.exists?(@other_task)).to be true
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
        @asset = Admin::UploadedAsset.find_by(name: 'splash-low').to_param
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
