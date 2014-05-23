# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Datasets::AnalysisTasksController do

  before(:each) do
    @user = create(:user)
    sign_in @user

    @dataset = create(:full_dataset, user: @user, working: true)
  end

  describe '#index' do
    context 'with a valid dataset' do
      it 'loads successfully' do
        get :index, dataset_id: @dataset.to_param
        expect(response).to be_success
      end

      it 'assigns dataset' do
        get :index, dataset_id: @dataset.to_param
        expect(assigns(:dataset)).to eq(@dataset)
      end
    end

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = create(:dataset, user: @user, name: 'Disabled',
                                     disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :index, dataset_id: @disabled.to_param
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with an invalid dataset' do
      it 'raises an error' do
        expect {
          get :index, dataset_id: 'asdf'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#new' do
    context 'when an invalid class is passed' do
      it 'raises an exception' do
        expect {
          get :new, dataset_id: @dataset.to_param, class: 'ThisIsNoClass'
        }.to raise_error
      end
    end

    context 'when Base is passed' do
      it 'raises an exception' do
        expect {
          get :new, dataset_id: @dataset.to_param, class: 'Base'
        }.to raise_error
      end
    end

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = create(:dataset, user: @user, name: 'Disabled',
                                     disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :new, dataset_id: @disabled.to_param, class: 'ArticleDates'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with valid parameters' do
      it 'loads successfully' do
        get :new, dataset_id: @dataset.to_param, class: 'ExportCitations',
                  job_params: { format: 'bibtex' }

        expect(response).to be_success
      end
    end
  end

  describe '#create' do
    context 'when an invalid class is passed' do
      it 'raises an exception' do
        expect {
          post :create, dataset_id: @dataset.to_param, class: 'ThisIsNoClass'
        }.to raise_error
      end
    end

    context 'when Base is passed' do
      it 'raises an exception' do
        expect {
          post :create, dataset_id: @dataset.to_param, class: 'Base'
        }.to raise_error
      end
    end

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = create(:dataset, user: @user, name: 'Disabled',
                                     disabled: true)
      end

      it 'raises an exception' do
        expect {
          post :create, dataset_id: @disabled.to_param, class: 'ArticleDates'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a valid class and params are passed' do
      it 'does not raise an exception' do
        expect {
          post :create, dataset_id: @dataset.to_param,
                        class: 'ExportCitations',
                        job_params: { format: 'bibtex' }
        }.to_not raise_error
      end

      it 'enqueues a job' do
        post :create, dataset_id: @dataset.to_param, class: 'ExportCitations',
                      job_params: { format: 'bibtex' }

        @dataset.analysis_tasks.reload
        task_id = @dataset.analysis_tasks.first.to_param

        expect(Jobs::Analysis::ExportCitations).to have_queued(
          @dataset.analysis_tasks.first.resque_key,
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: task_id,
          format: 'bibtex')
      end

      it 'redirects to the dataset page' do
        post :create, dataset_id: @dataset.to_param, class: 'ExportCitations',
                      job_params: { format: 'bibtex' }
        expect(response).to redirect_to(dataset_path(@dataset))
      end
    end

    context 'when a valid class/params are passed at the end of a workflow' do
      before(:each) do
        @user.workflow_active = true
        @user.workflow_datasets = [@dataset]
        @user.workflow_class = 'ExportCitations'
        @user.save

        post :create, dataset_id: @dataset.to_param, class: 'ExportCitations',
                      job_params: { format: 'bibtex' }

        @user.reload
      end

      it 'clears the workflow parameters' do
        expect(@user.workflow_active).to be false
        expect(@user.workflow_class).to be_nil
        expect(@user.workflow_datasets).to be_blank
      end

      it 'redirects to the root' do
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#show' do
    before(:each) do
      @task = create(:analysis_task, dataset: @dataset,
                                     job_type: 'ExportCitations')
    end

    context 'when an invalid task ID is passed' do
      it 'raises an exception' do
        expect {
          get :show, dataset_id: @dataset.to_param,
                     id: '12345678', view: 'test'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = create(:dataset, user: @user, name: 'Disabled',
                                     disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :show, dataset_id: @disabled.to_param, id: @task.to_param, view: '_params'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when rendering a job view' do
      # We want to let it render views, to make sure that the search path
      # addition is working properly
      render_views

      it 'raises an exception for missing views' do
        expect {
          get :show, dataset_id: @dataset.to_param,
                     id: @task.to_param, view: 'notaview'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not raise an exception' do
        expect {
          get :show, dataset_id: @dataset.to_param,
                     id: @task.to_param, view: '_params'
        }.to_not raise_error
      end

      it 'renders the right view' do
        get :show, dataset_id: @dataset.to_param,
                   id: @task.to_param, view: '_params'
        expect(response.body).to include('<option')
      end
    end

    context 'when fetching a task download' do
      before(:each) do
        Jobs::Analysis::ExportCitations.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param,
          format: 'bibtex'
        )
      end

      it 'loads successfully' do
        get :show, dataset_id: @dataset.to_param, id: @task.to_param
        expect(response).to be_success
      end

      it 'has the right MIME type' do
        get :show, dataset_id: @dataset.to_param, id: @task.to_param
        expect(response.content_type).to eq('application/zip')
      end

      it 'sends some data' do
        get :show, dataset_id: @dataset.to_param, id: @task.to_param
        expect(response.body.length).to be > 0
      end
    end
  end

  describe '#destroy' do
    context 'when an invalid task ID is passed' do
      it 'raises an exception' do
        expect {
          get :destroy, dataset_id: @dataset.to_param, id: '12345678'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = create(:dataset, user: @user, name: 'Disabled',
                                     disabled: true)
        @task = create(:analysis_task, dataset: @disabled,
                                       job_type: 'ExportCitations')
      end

      it 'raises an exception' do
        expect {
          get :destroy, dataset_id: @disabled.to_param, id: @task.to_param
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a valid task ID is passed' do
      before(:each) do
        request.env['HTTP_REFERER'] = workflow_fetch_path
        @task = create(:analysis_task, dataset: @dataset,
                                       job_type: 'ExportCitations')
      end

      it 'deletes the task' do
        expect {
          get :destroy, dataset_id: @dataset.to_param, id: @task.to_param
        }.to change { @dataset.analysis_tasks.count }.by(-1)
      end

      it 'redirects to the prior page' do
        get :destroy, dataset_id: @dataset.to_param, id: @task.to_param
        expect(response).to redirect_to(workflow_fetch_path)
      end
    end
  end
end
