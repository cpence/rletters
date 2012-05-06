# -*- encoding : utf-8 -*-
require 'spec_helper'

shared_context "create job with params" do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset,
                                  { :user => @user,
                                    :working => true,
                                    :entries_count => 10 }.merge(dataset_params))
    described_class.new({ :user_id => @user.to_param,
                          :dataset_id => @dataset.to_param }.merge(job_params)).perform
  end
end


shared_examples_for 'an analysis job' do
  # Defaults for the configuration parameters -- specify these in a
  # customization block if you need extra/different parameters to create
  # your job or dataset.
  def job_params
    {}
  end
  def dataset_params
    {}
  end
  
  context "when the wrong user is specified" do
    it "raises an exception" do
      expect {
        described_class.new(job_params.merge({ :user_id => FactoryGirl.create(:user).to_param, 
                                               :dataset_id => @dataset.to_param })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid user is specified" do
    it "raises an exception" do
      expect {
        described_class.new(job_params.merge({ :user_id => '123123123123123', 
                                               :dataset_id => @dataset.to_param })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid dataset is specified" do
    it "raises an exception" do
      expect {
        described_class.new(job_params.merge({ :user_id => @user.to_param, 
                                               :dataset_id => '123123123123' })).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "when all parameters are valid" do
    include_context "create job with params"
    
    it "creates an analysis task" do
      @dataset.analysis_tasks.should have(1).items
      @dataset.analysis_tasks[0].should be
    end
  end
end

shared_examples_for 'an analysis job with a file' do
  include_examples 'an analysis job'

  context "when a file is made" do
    include_context "create job with params"
    
    it "makes a file for the task" do
      @dataset.analysis_tasks[0].result_file.should be
    end
    
    it "creates the file on disk" do
      File.exists?(@dataset.analysis_tasks[0].result_file.filename).should be_true
    end
  end
end
