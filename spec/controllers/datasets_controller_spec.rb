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
        expect(response).to redirect_to(root_path)
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

      it 'ignores disabled datasets' do
        disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled',
                                                disabled: true)
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
    context 'with no workflow active' do
      before(:each) do
        post :create, { dataset: { name: 'Disabled Dataset' },
                        q: '*:*', fq: nil, defType: 'lucene' }
        @user.datasets.reload
      end

      it 'creates a delayed job' do
        expect(Jobs::CreateDataset).to have_queued(user_id: @user.to_param,
                                                   dataset_id: @user.datasets.inactive[0].to_param,
                                                   q: '*:*',
                                                   fq: nil,
                                                   defType: 'lucene')
      end

      it 'creates a skeleton dataset' do
        expect(@user.datasets.count).to eq(2)
      end

      it 'makes that dataset inactive' do
        expect(@user.datasets.active.count).to eq(1)

        expect(@user.datasets.inactive.count).to eq(1)
        expect(@user.datasets.inactive[0].name).to eq('Disabled Dataset')
      end

      it 'redirects to index when done' do
        expect(response).to redirect_to(datasets_path)
      end
    end

    context 'with an active workflow' do
      it 'redirects to the workflow activation when workflow is active' do
        @user.workflow_active = true
        @user.workflow_class = 'PlotDates'
        @user.save

        post :create, { dataset: { name: 'Disabled Dataset' },
                        q: '*:*', fq: nil, defType: 'lucene' }
        @user.datasets.reload

        expect(response).to redirect_to(workflow_activate_path('PlotDates'))
        expect(flash[:success]).to be
      end
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

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled',
                                                 disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :show, id: @disabled.to_param
        }.to raise_error(ActiveRecord::RecordNotFound)
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

  describe '#destroy' do
    before(:each) do
      delete :destroy, id: @dataset.to_param
    end

    it 'creates a delayed job' do
      expect(Jobs::DestroyDataset).to have_queued(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param)
    end

    it 'redirects to the index when done' do
      expect(response).to redirect_to(datasets_path)
    end

    it 'disables the dataset' do
      @user.datasets.reload
      @dataset.reload

      expect(@user.datasets.active.count).to eq(0)
      expect(@user.datasets.inactive.count).to eq(1)
      expect(@dataset.disabled).to be_true
    end
  end

  describe '#add' do
    context 'when an invalid document is passed' do
      it 'raises an exception' do
        expect {
          get :add, dataset_id: @dataset.to_param, uid: 'fail'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled',
                                                 disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :add, id: @disabled.to_param, uid: FactoryGirl.generate(:working_uid)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when all parameters are valid' do
      it 'adds to the dataset' do
        expect {
          get :add, dataset_id: @dataset.to_param,
                    uid: FactoryGirl.generate(:working_uid)
        }.to change { @dataset.entries.count }.by(1)
      end

      it 'redirects to the dataset page' do
        get :add, dataset_id: @dataset.to_param,
                  uid: FactoryGirl.generate(:working_uid)
        expect(response).to redirect_to(dataset_path(@dataset))
      end
    end

    context 'with a remote document' do
      it 'sets the fetch flag' do
        expect(@dataset.fetch).to be_false

        get :add, dataset_id: @dataset.to_param, uid: 'gutenberg:3172'
        @dataset.reload

        expect(@dataset.fetch).to be_true
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

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled',
                                                 disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :task_start, id: @disabled.to_param, class: 'PlotDates'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a valid class is passed without start' do
      it 'does not raise an exception' do
        expect {
          get :task_start, id: @dataset.to_param, class: 'ExportCitations',
                           job_params: { format: 'bibtex' }
        }.to_not raise_error
      end

      it 'does not enqueue a job' do
        get :task_start, id: @dataset.to_param, class: 'ExportCitations',
                         job_params: { format: 'bibtex' }

        expect(Jobs::Analysis::ExportCitations).to_not have_queued
      end

      it 'renders the parameters view' do
        get :task_start, id: @dataset.to_param, class: 'ExportCitations',
                         job_params: { format: 'bibtex' }

        expect(response).to render_template(:task_params)
      end
    end

    context 'when a valid class is passed that needs more datasets' do
      before(:each) do
        get(:task_start, id: @dataset.to_param, class: 'CraigZeta',
                         job_params: { })
      end

      it 'renders the task_datasets view' do
        expect(response).to render_template(:task_datasets)
      end
    end

    context 'when a valid class is passed that needs and has more datasets' do
      before(:each) do
        @other_dataset = FactoryGirl.create(:dataset, user: @user)
        get(:task_start, id: @dataset.to_param, class: 'CraigZeta',
                         job_params: { other_datasets: [@other_dataset.to_param],
                                       start: true })

        @dataset.analysis_tasks.reload
        @task_id = @dataset.analysis_tasks[0].to_param
      end

      it 'enqueues a job' do
        expect(Jobs::Analysis::CraigZeta).to have_queued(
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task_id,
          other_datasets: [@other_dataset.to_param],
          start: true)
      end
    end

    context 'when a valid class is passed with start' do
      it 'does not raise an exception' do
        expect {
          get :task_start, id: @dataset.to_param, class: 'ExportCitations',
                           job_params: { format: 'bibtex', start: 'true' }
        }.to_not raise_error
      end

      it 'enqueues a job' do
        get :task_start, id: @dataset.to_param, class: 'ExportCitations',
                         job_params: { format: 'bibtex', start: 'true' }

        @dataset.analysis_tasks.reload
        task_id = @dataset.analysis_tasks[0].to_param

        expect(Jobs::Analysis::ExportCitations).to have_queued(
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: task_id,
          format: 'bibtex',
          start: 'true')
      end

      it 'redirects to the dataset page' do
        get :task_start, id: @dataset.to_param, class: 'ExportCitations',
                         job_params: { format: 'bibtex', start: 'true' }
        expect(response).to redirect_to(dataset_path(@dataset))
      end
    end

    context 'when a valid class is passed at the end of a workflow' do
      before(:each) do
        @user.workflow_active = true
        @user.workflow_datasets = [@dataset.to_param].to_json
        @user.workflow_class = 'ExportCitations'
        @user.save

        get(:task_start, id: @dataset.to_param, class: 'ExportCitations',
                         job_params: { format: 'bibtex', start: 'true' })

        @user.reload
      end

      it 'clears the workflow parameters' do
        expect(@user.workflow_active).to be_false
        expect(@user.workflow_class).to be_nil
        expect(@user.workflow_datasets).to be_nil
      end

      it 'redirects to the root' do
        expect(response).to redirect_to(root_path)
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

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled',
                                                 disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :task_view, id: @disabled.to_param, class: 'PlotDates', view: '_params'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a valid task ID is passed' do
      # We want to let it render views, to make sure that the search path
      # addition is working properly
      render_views

      before(:each) do
        @task = FactoryGirl.create(:analysis_task,
                                   dataset: @dataset,
                                   job_type: 'ExportCitations')
      end

      it 'raises an exception for missing views' do
        expect {
          get :task_view, id: @dataset.to_param,
                          task_id: @task.to_param, view: 'notaview'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'does not raise an exception' do
        expect {
          get :task_view, id: @dataset.to_param,
                          task_id: @task.to_param, view: '_params'
        }.to_not raise_error
      end

      it 'renders the right view' do
        get :task_view, id: @dataset.to_param,
                        task_id: @task.to_param, view: '_params'
        expect(response.body).to include('<option')
      end
    end

    context 'when a valid task class is passed' do
      it 'does not raise an exception' do
        expect {
          get :task_view, id: @dataset.to_param, class: 'ExportCitations',
                          view: '_params'
        }.to_not raise_error
      end
    end
  end

  describe '#task_download' do
    before(:each) do
      @task = FactoryGirl.create(:analysis_task, dataset: @dataset)
      Jobs::Analysis::ExportCitations.perform(
        user_id: @user.to_param,
        dataset_id: @dataset.to_param,
        task_id: @task.to_param,
        format: :bibtex
      )
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

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled',
                                                 disabled: true)
        @task = FactoryGirl.create(:analysis_task,
                                   dataset: @disabled,
                                   job_type: 'ExportCitations')
      end

      it 'raises an exception' do
        expect {
          get :task_destroy, id: @disabled.to_param, task_id: @task.to_param
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when a valid task ID is passed' do
      before(:each) do
        request.env['HTTP_REFERER'] = workflow_fetch_path
        @task = FactoryGirl.create(:analysis_task,
                                   dataset: @dataset,
                                   job_type: 'ExportCitations')
      end

      it 'deletes the task' do
        expect {
          get :task_destroy, id: @dataset.to_param, task_id: @task.to_param
        }.to change { @dataset.analysis_tasks.count }.by(-1)
      end

      it 'redirects to the prior page' do
        get :task_destroy, id: @dataset.to_param, task_id: @task.to_param
        expect(response).to redirect_to(workflow_fetch_path)
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

    context 'with a disabled dataset' do
      before(:each) do
        @disabled = FactoryGirl.create(:dataset, user: @user, name: 'Disabled',
                                                 disabled: true)
      end

      it 'raises an exception' do
        expect {
          get :task_list, id: @disabled.to_param
        }.to raise_error(ActiveRecord::RecordNotFound)
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
