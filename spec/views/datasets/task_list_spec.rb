# -*- encoding : utf-8 -*-
require 'spec_helper'

describe "datasets/task_list" do
  
  login_user
  
  before(:each) do
    @dataset = FactoryGirl.create(:full_dataset, :user => @user)
    assign(:dataset, @dataset)    
    params[:id] = @dataset.to_param
  end
  
  it 'shows pending analysis tasks' do
    task = FactoryGirl.create(:analysis_task, :dataset => @dataset)
    render
    
    rendered.should have_selector("li[data-theme=e]", :content => '1 analysis task pending for this dataset...')
  end
  
  context 'with completed analysis tasks' do
    before(:each) do
      # This needs to be a real job type, since we're making URLs
      @task = FactoryGirl.create(:analysis_task, :name => 'test', :dataset => @dataset,
                                 :job_type => "ExportCitations", :finished_at => 5.minutes.ago)
      render      
    end
    
    it 'shows the name of the job' do
      rendered.should contain("“test” Complete")      
    end
    
    it 'shows a link to download the results' do
      expected = url_for(:controller => 'datasets', :action => 'task_download', 
        :id => @dataset.to_param, :task_id => @task.to_param)    
      rendered.should have_selector("a[href='#{expected}']")      
    end
    
    it 'shows a link to delete the task' do
      expected = url_for(:controller => 'datasets', :action => 'task_destroy', 
        :id => @dataset.to_param, :task_id => @task.to_param)    
      rendered.should have_selector("a[href='#{expected}']")            
    end
  end
  
  context 'with failed analysis tasks' do
    before(:each) do
      @task = FactoryGirl.create(:analysis_task, :dataset => @dataset, :failed => true)
      render
    end
    
    it 'shows failed analysis tasks' do
      rendered.should contain('1 analysis task failed for this dataset!')
    end
    
    it 'shows a link to clear failed analysis tasks' do
      rendered.should have_selector("a[href='#{dataset_path(@dataset, :clear_failed => true)}']")
    end
  end
  
end
