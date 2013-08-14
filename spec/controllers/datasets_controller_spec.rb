# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetsController do

  before(:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user

    @dataset = FactoryGirl.create(:full_dataset, user: @user, working: true)
  end

  describe '#index' do
    context 'when not logged in' do
      before(:each) do
        sign_out :user
      end

      it 'redirects to the login page' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when logged in' do
      it 'loads successfully' do
        get :index
        expect(response).to be_success
      end
    end
  end

  describe '#dataset_list' do
    context 'when logged in' do
      it 'loads successfully' do
        get :dataset_list
        expect(response).to be_success
      end

      it 'assigns the list of datsets' do
        get :dataset_list
        expect(assigns(:datasets)).to eq([@dataset])
      end
    end
  end

  describe '#new' do
    it 'loads successfully' do
      get :new
      expect(response).to be_success
    end

    it 'assigns dataset' do
      get :new
      expect(assigns(:dataset)).to be_new_record
    end
  end

  describe '#create' do
    it 'creates a delayed job' do
      expected_job = Jobs::CreateDataset.new(
        user_id: @user.to_param,
        name: 'Test Dataset',
        q: '*:*',
        fq: nil,
        defType: 'lucene')
      expect(Delayed::Job).to receive(:enqueue).with(
        expected_job,
        queue: 'ui'
      ).once

      post :create, { dataset: { name: 'Test Dataset' },
        q: '*:*', fq: nil, defType: 'lucene' }
    end

    it 'redirects to index when done' do
      post :create, { dataset: { name: 'Test Dataset' },
        q: '*:*', fq: nil, defType: 'lucene' }
      expect(response).to redirect_to(datasets_path)
    end
  end

  describe '#show' do
    context 'without clear_failed' do
      it 'loads successfully' do
        get :show, id: @dataset.to_param
        expect(response).to be_success
      end

      it 'assigns dataset' do
        get :show, id: @dataset.to_param
        expect(assigns(:dataset)).to eq(@dataset)
      end
    end

    context 'with clear_failed' do
      before(:each) do
        task = FactoryGirl.build(:analysis_task, dataset: @dataset)
        task.failed = true
        expect(task.save).to be_true

        get :show, id: @dataset.to_param, clear_failed: true
      end

      it 'loads successfully' do
        expect(response).to be_success
      end

      it 'deletes the failed task' do
        expect(@dataset.analysis_tasks.failed.count).to eq(0)
      end

      it 'sets the flash' do
        expect(flash[:notice]).not_to be_nil
      end
    end
  end

  describe '#delete' do
    it 'loads successfully' do
      get :delete, id: @dataset.to_param
      expect(response).to be_success
    end

    it 'assigns dataset' do
      get :delete, id: @dataset.to_param
      expect(assigns(:dataset)).to eq(@dataset)
    end
  end

  describe '#destroy' do
    context 'when cancel is not passed' do
      it 'creates a delayed job' do
        expected_job = Jobs::DestroyDataset.new(
          user_id: @user.to_param,
          dataset_id: @dataset.to_param)
        expect(Delayed::Job).to receive(:enqueue).with(
          expected_job,
          queue: 'ui'
        ).once

        delete :destroy, id: @dataset.to_param
      end

      it 'redirects to index when done' do
        delete :destroy, id: @dataset.to_param
        expect(response).to redirect_to(datasets_path)
      end
    end

    context 'when cancel is passed' do
      it 'does not create a delayed job' do
        expect(Delayed::Job).not_to receive(:enqueue)
        delete :destroy, id: @dataset.to_param, cancel: true
      end

      it 'redirects to the dataset page' do
        delete :destroy, id: @dataset.to_param, cancel: true
        expect(response).to redirect_to(@dataset)
      end
    end
  end

  describe '#add' do
    context 'when an invalid document is passed',
            vcr: { cassette_name: 'solr_fail' } do
      it 'raises an exception' do
        expect {
          get :add, dataset_id: @dataset.to_param, shasum: 'fail'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when all parameters are valid',
            vcr: { cassette_name: 'solr_single' } do
      it 'adds to the dataset' do
        expect {
          get :add, dataset_id: @dataset.to_param,
              shasum: FactoryGirl.generate(:working_shasum)
        }.to change { @dataset.entries.count }.by(1)
      end

      it 'redirects to the dataset page',
         vcr: { cassette_name: 'solr_single' } do
        get :add, dataset_id: @dataset.to_param,
            shasum: FactoryGirl.generate(:working_shasum)
        expect(response).to redirect_to(dataset_path(@dataset))
      end
    end
  end

  describe '#task_start' do
    context 'when an invalid class is passed' do
      it 'raises an exception' do
        expect {
          get :task_start, id: @dataset.to_param, class: 'ThisIsNoClass'
        }.to raise_error
      end
    end

    context 'when Base is passed' do
      it 'raises an exception' do
        expect {
          get :task_start, id: @dataset.to_param, class: 'Base'
        }.to raise_error
      end
    end

    context 'when a valid class is passed' do
      it 'does not raise an exception' do
        expect {
          get :task_start, id: @dataset.to_param, class: 'ExportCitations',
              job_params: { format: 'bibtex' }
        }.to_not raise_error
      end

      it 'enqueues a job' do
        expected_job = Jobs::Analysis::ExportCitations.new(
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          format: 'bibtex')
        expect(Delayed::Job).to receive(:enqueue).with(
          expected_job,
          queue: 'analysis'
        ).once

        get :task_start, id: @dataset.to_param, class: 'ExportCitations',
            job_params: { format: 'bibtex' }
      end

      it 'redirects to the dataset page' do
        get :task_start, id: @dataset.to_param, class: 'ExportCitations',
            job_params: { format: 'bibtex' }
        expect(response).to redirect_to(dataset_path(@dataset))
      end
    end
  end

  describe '#task_view' do
    context 'when an invalid task ID is passed' do
      it 'raises an exception' do
        expect {
          get :task_view, id: @dataset.to_param,
              task_id: '12345678', view: 'test'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when an invalid task class is passed' do
      it 'raises an exception' do
        expect {
          get :task_view, id: @dataset.to_param, class: 'NotClass',
          view: 'test'
        }.to raise_error(ArgumentError)
      end
    end

    context 'when a valid task ID is passed' do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task, dataset: @dataset,
                                   job_type: 'ExportCitations')
      end

      after(:each) do
        @task.destroy
      end

      it 'does not raise an exception' do
        expect {
          get :task_view, id: @dataset.to_param,
              task_id: @task.to_param, view: 'start'
        }.to_not raise_error
      end
    end

    context 'when a valid task class is passed' do
      it 'does not raise an exception' do
        expect {
          get :task_view, id: @dataset.to_param, class: 'ExportCitations',
              view: 'start'
        }.to_not raise_error
      end
    end
  end

  describe '#task_download', vcr: { cassette_name: 'solr_single' } do
    before(:each) do
      # Execute an export job, which should create an AnalysisTask
      Jobs::Analysis::ExportCitations.new(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        format: :bibtex
      ).perform

      # Double-check that the task is created
      expect(@dataset.analysis_tasks).to have(1).item
      expect(@dataset.analysis_tasks[0]).to be

      @task = @dataset.analysis_tasks[0]
    end

    after(:each) do
      @task.destroy
    end

    it 'loads successfully' do
      get :task_download, id: @dataset.to_param, task_id: @task.to_param
      expect(response).to be_success
    end

    it 'has the right MIME type' do
      get :task_download, id: @dataset.to_param, task_id: @task.to_param
      expect(response.content_type).to eq('application/zip')
    end

    it 'sends some data' do
      get :task_download, id: @dataset.to_param, task_id: @task.to_param
      expect(response.body.length).to be > 0
    end
  end

  describe '#task_destroy' do
    context 'when an invalid task ID is passed' do
      it 'raises an exception' do
        expect {
          get :task_destroy, id: @dataset.to_param, task_id: '12345678'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when cancel is pressed' do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task, dataset: @dataset,
                                   job_type: 'ExportCitations')
      end

      after(:each) do
        @task.destroy
      end

      it 'does not delete the task' do
        expect {
          get :task_destroy, id: @dataset.to_param,
              task_id: @task.to_param, cancel: true
        }.to_not change { @dataset.analysis_tasks.count }
      end

      it 'redirects to the dataset page' do
        get :task_destroy, id: @dataset.to_param,
            task_id: @task.to_param, cancel: true
        expect(response).to redirect_to(dataset_path(@dataset))
      end
    end

    context 'when cancel is not pressed' do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task, dataset: @dataset,
                                   job_type: 'ExportCitations')
      end

      it 'deletes the task' do
        expect {
          get :task_destroy, id: @dataset.to_param, task_id: @task.to_param
        }.to change { @dataset.analysis_tasks.count }.by(-1)
      end

      it 'redirects to the dataset page' do
        get :task_destroy, id: @dataset.to_param, task_id: @task.to_param
        expect(response).to redirect_to(dataset_path(@dataset))
      end
    end
  end

  describe '#task_list' do
    context 'with a valid dataset' do
      it 'loads successfully' do
        get :task_list, id: @dataset.to_param
        expect(response).to be_success
      end

      it 'assigns dataset' do
        get :task_list, id: @dataset.to_param
        expect(assigns(:dataset)).to eq(@dataset)
      end
    end

    context 'with an invalid dataset' do
      it 'raises an error' do
        expect {
          get :task_list, id: 'asdf'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

end
