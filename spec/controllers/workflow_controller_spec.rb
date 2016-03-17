require 'rails_helper'

# Mock job class for the workflow controller
class WorkflowJob < ApplicationJob
  def perform(task); end
end

RSpec.describe WorkflowController, type: :controller do
  describe '#index' do
    context 'given Solr results' do
      context 'when logged in' do
        before(:example) do
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
          expect(assigns(:database_size)).to eq(1502)
        end
      end

      context 'when not logged in' do
        before(:example) do
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
    before(:example) do
      @user = create(:user)
      sign_in @user

      @dataset = create(:dataset, name: 'Test Dataset', working: true,
                                  user: @user)
    end

    describe '#info' do
      it 'loads successfully' do
        get :info, params: { class: 'ArticleDatesJob' }
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
      before(:example) do
        @user.workflow_active = true
        @user.workflow_class = 'ArticleDatesJob'
        @user.workflow_datasets = [@dataset.to_param]

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
        before(:example) do
          get :activate, params: { class: 'ArticleDatesJob' }
          @user.reload
        end

        it 'sets the workflow parameters' do
          expect(@user.workflow_active).to be true
          expect(@user.workflow_class).to eq('ArticleDatesJob')
          expect(@user.workflow_datasets).to be_blank
        end
      end

      context 'when asked to link a dataset' do
        before(:example) do
          get :activate, params: { class: 'ArticleDatesJob',
                                   link_dataset_id: @dataset.to_param }
          @user.reload
        end

        it 'sets the right parameters' do
          expect(@user.workflow_active).to be true
          expect(@user.workflow_class).to eq('ArticleDatesJob')
          expect(@user.workflow_datasets).to eq([@dataset.to_param])
        end
      end

      context 'when asked to unlink an invalid dataset' do
        before(:example) do
          @user.workflow_active = true
          @user.workflow_class = 'ArticleDatesJob'
          @user.workflow_datasets = [@dataset.to_param]
          @user.save
        end

        it 'raises an error' do
          expect {
            get :activate, params: { class: 'ArticleDatesJob',
                                     unlink_dataset_id: '999' }
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context 'when asked to unlink a dataset with one dataset' do
        before(:example) do
          @user.workflow_active = true
          @user.workflow_class = 'ArticleDatesJob'
          @user.workflow_datasets = [@dataset.to_param]
          @user.save

          get :activate, params: { class: 'ArticleDatesJob',
                                   unlink_dataset_id: @dataset.to_param }
          @user.reload
        end

        it 'unlinks the dataset' do
          expect(@user.workflow_datasets).to be_blank
        end
      end

      context 'when asked to unlink a dataset with multiple datasets' do
        before(:example) do
          @dataset_2 = create(:dataset, user: @user)

          @user.workflow_active = true
          @user.workflow_class = 'CraigZetaJob'
          @user.workflow_datasets = [@dataset.to_param, @dataset_2.to_param]
          @user.save

          get :activate, params: { class: 'CraigZetaJob',
                                   unlink_dataset_id: @dataset_2.to_param }
          @user.reload
        end

        it 'unlinks the dataset' do
          expect(@user.workflow_datasets).to eq([@dataset.to_param])
        end
      end
    end
  end

  describe '#fetch' do
    def make_task(dataset, finished, args = {})
      task = create(:task, args.merge(dataset: dataset, finished_at: finished,
                                      job_type: 'WorkflowJob'))

      WorkflowJob.perform_later(task)

      task
    end

    before(:example) do
      @user = create(:user)
      @user2 = create(:user)
      sign_in @user

      @dataset = create(:dataset, user: @user, name: 'Enabled')
      @other_dataset = create(:dataset, user: @user2, name: 'OtherUser')

      @finished_task = make_task(@dataset, DateTime.now)
      @pending_task = make_task(@dataset, nil)
      @working_task = make_task(@dataset, nil, progress: 0.3)
      @failed_task = make_task(@dataset, nil, failed: true)

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
      before(:example) do
        get :fetch, params: { terminate: true }
      end

      it 'destroys the tasks' do
        expect(Datasets::Task.exists?(@pending_task.id)).to be false
        expect(Datasets::Task.exists?(@working_task.id)).to be false
        expect(Datasets::Task.exists?(@failed_task.id)).to be false
      end

      it 'leaves everything else alone' do
        expect(Datasets::Task.exists?(@finished_task.id)).to be true
        expect(Datasets::Task.exists?(@other_task.id)).to be true
      end

      it 'redirects to the workflow index' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets a flash alert' do
        expect(flash[:alert]).to be
      end
    end

    context 'with an XHR request' do
      before do
        get :fetch, xhr: true
      end

      it 'loads successfully' do
        expect(response).to be_success
      end

      it 'renders the XHR version of the template' do
        expect(response).to render_template(:fetch_xhr)
      end

      it 'renders no layout' do
        expect(response.body).not_to include('<html')
      end
    end
  end

  describe '#image' do
    context 'with an invalid id' do
      it 'returns a 404' do
        expect {
          get :image, params: { id: '123456789' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a valid id' do
      before(:example) do
        @asset = create(:uploaded_asset).to_param
        @id = @asset.to_param

        get :image, params: { id: @id }
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
