# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetsController do
  
  login_user  
  before(:each) do
    @dataset = FactoryGirl.create(:full_dataset, :user => @user, :working => true)
  end
  
  describe '#index' do
    context "when not logged in" do
      logout_user

      it "redirects to the users page" do
        get :index
        response.should redirect_to(user_path)
      end
    end
    
    context "when logged in" do
      it "loads successfully" do
        get :index
        response.should be_success
      end
    end
  end
  
  describe '#dataset_list' do
    context "when logged in" do
      it "loads successfully" do
        get :dataset_list
        response.should be_success
      end
      
      it "assigns the list of datsets" do
        get :dataset_list
        assigns(:datasets).should eq([ @dataset ])
      end
    end
  end
  
  describe '#new' do
    it 'loads successfully' do
      get :new
      response.should be_success
    end
    
    it 'assigns dataset' do
      get :new
      assigns(:dataset).should be_new_record
    end
  end
  
  describe '#create' do
    it 'creates a delayed job' do
      expected_job = Jobs::CreateDataset.new(
        :user_id => @user.to_param,
        :name => 'Test Dataset',
        :q => '*:*',
        :fq => nil,
        :qt => 'precise')
      Delayed::Job.should_receive(:enqueue).with(expected_job).once
      
      post :create, { :dataset => { :name => 'Test Dataset' }, 
        :q => '*:*', :fq => nil, :qt => 'precise' }
    end
    
    it 'redirects to index when done' do
      post :create, { :dataset => { :name => 'Test Dataset' }, 
        :q => '*:*', :fq => nil, :qt => 'precise' }
      response.should redirect_to(datasets_path)
    end
  end
  
  describe '#show' do
    context 'without clear_failed' do
      it 'loads successfully' do
        get :show, :id => @dataset.to_param
        response.should be_success
      end

      it 'assigns dataset' do
        get :show, :id => @dataset.to_param
        assigns(:dataset).should eq(@dataset)
      end
    end
    
    context 'with clear_failed' do
      before(:each) do
        task = FactoryGirl.build(:analysis_task, :dataset => @dataset)
        task.failed = true
        task.save.should be_true

        get :show, :id => @dataset.to_param, :clear_failed => true
      end

      it 'loads successfully' do
        response.should be_success
      end
      
      it 'deletes the failed task' do
        @dataset.analysis_tasks.failed.count.should eq(0)
      end
      
      it 'sets the flash' do
        flash[:notice].should_not be_nil
      end
    end
  end
  
  describe '#delete' do
    it 'loads successfully' do
      get :delete, :id => @dataset.to_param
      response.should be_success
    end
    
    it 'assigns dataset' do
      get :delete, :id => @dataset.to_param
      assigns(:dataset).should eq(@dataset)
    end
  end
  
  describe '#destroy' do
    context 'when cancel is not passed' do
      it 'creates a delayed job' do
        expected_job = Jobs::DestroyDataset.new(
          :user_id => @user.to_param,
          :dataset_id => @dataset.to_param)
        Delayed::Job.should_receive(:enqueue).with(expected_job).once

        delete :destroy, :id => @dataset.to_param
      end
      
      it 'redirects to index when done' do
        delete :destroy, :id => @dataset.to_param
        response.should redirect_to(datasets_path)
      end
    end
    
    context 'when cancel is passed' do
      it 'does not create a delayed job' do
        Delayed::Job.should_not_receive(:enqueue)
        delete :destroy, :id => @dataset.to_param, :cancel => true
      end
      
      it 'redirects to the dataset page' do
        delete :destroy, :id => @dataset.to_param, :cancel => true
        response.should redirect_to(@dataset)
      end
    end
  end

  describe '#add' do
    context 'when an invalid document is passed' do
      it 'raises an exception' do
        expect {
          get :add, :dataset_id => @dataset.to_param, :shasum => 'fail'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when all parameters are valid' do
      it 'adds to the dataset' do
        expect {
          get :add, :dataset_id => @dataset.to_param, :shasum => FactoryGirl.generate(:working_shasum)
        }.to change{@dataset.entries.count}.by(1)
      end

      it 'redirects to the dataset page' do
        get :add, :dataset_id => @dataset.to_param, :shasum => FactoryGirl.generate(:working_shasum)
        response.should redirect_to(dataset_path(@dataset))
      end
    end
  end
  
  describe '#task_start' do
    context 'when an invalid class is passed' do
      it 'raises an exception' do
        expect {
          get :task_start, :id => @dataset.to_param, :class => 'ThisIsNoClass'
        }.to raise_error
      end
    end
    
    context 'when Base is passed' do
      it 'raises an exception' do
        expect {
          get :task_start, :id => @dataset.to_param, :class => 'Base'
        }.to raise_error
      end
    end
    
    context 'when a valid class is passed' do
      it 'does not raise an exception' do
        expect {
          get :task_start, :id => @dataset.to_param, :class => 'ExportCitations', :job_params => { :format => 'bibtex' }
        }.to_not raise_error
      end
      
      it 'enqueues a job' do
        expected_job = Jobs::Analysis::ExportCitations.new(
          :user_id => @user.to_param,
          :dataset_id => @dataset.to_param,
          :format => 'bibtex')
        Delayed::Job.should_receive(:enqueue).with(expected_job).once
        
        get :task_start, :id => @dataset.to_param, :class => 'ExportCitations', :job_params => { :format => 'bibtex' }
      end
      
      it 'redirects to the dataset page' do
        get :task_start, :id => @dataset.to_param, :class => 'ExportCitations', :job_params => { :format => 'bibtex' }
        response.should redirect_to(dataset_path(@dataset))
      end
    end
  end
  
  describe '#task_view' do
    context 'when an invalid task ID is passed' do
      it 'raises an exception' do
        expect {
          get :task_view, :id => @dataset.to_param, :task_id => '12312312312312', :view => 'test'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context 'when a valid task ID is passed' do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task, :dataset => @dataset, :job_type => 'ExportCitations')
      end
      
      after(:each) do
        @task.destroy
      end
      
      it 'does not raise an exception' do
        expect {
          get :task_view, :id => @dataset.to_param, :task_id => @task.to_param, :view => 'start'
        }.to_not raise_error
      end
    end
  end
  
  describe '#task_download' do
    before(:each) do
      # Execute an export job, which should create an AnalysisTask
      Jobs::Analysis::ExportCitations.new(
        :user_id => @user.to_param,
        :dataset_id => @dataset.to_param,
        :format => :bibtex).perform

      # Double-check that the task is created
      @dataset.analysis_tasks.should have(1).item
      @dataset.analysis_tasks[0].should be
      
      @task = @dataset.analysis_tasks[0]
    end
    
    after(:each) do
      @task.destroy
    end
    
    it 'loads successfully' do
      get :task_download, :id => @dataset.to_param, :task_id => @task.to_param
      response.should be_success
    end
    
    it 'has the right MIME type' do
      get :task_download, :id => @dataset.to_param, :task_id => @task.to_param
      response.content_type.should eq('application/zip')
    end
    
    it 'sends some data' do
      get :task_download, :id => @dataset.to_param, :task_id => @task.to_param
      response.body.length.should be > 0
    end
  end
  
  describe "#task_destroy" do
    context 'when an invalid task ID is passed' do
      it 'raises an exception' do
        expect {
          get :task_destroy, :id => @dataset.to_param, :task_id => '12312312312312'
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context 'when cancel is pressed' do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task, :dataset => @dataset, :job_type => 'ExportCitations')
      end
      
      after(:each) do
        @task.destroy
      end
      
      it "doesn't delete the task" do
        expect {
          get :task_destroy, :id => @dataset.to_param, :task_id => @task.to_param, :cancel => true
        }.to_not change{@dataset.analysis_tasks.count}
      end
      
      it 'redirects to the dataset page' do
        get :task_destroy, :id => @dataset.to_param, :task_id => @task.to_param, :cancel => true
        response.should redirect_to(dataset_path(@dataset))
      end
    end
    
    context "when cancel is not pressed" do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task, :dataset => @dataset, :job_type => 'ExportCitations')
      end
      
      it "deletes the task" do
        expect {
          get :task_destroy, :id => @dataset.to_param, :task_id => @task.to_param
        }.to change{@dataset.analysis_tasks.count}.by(-1)
      end
      
      it 'redirects to the dataset page' do
        get :task_destroy, :id => @dataset.to_param, :task_id => @task.to_param
        response.should redirect_to(dataset_path(@dataset))
      end
    end
  end
  
end
