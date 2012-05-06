# -*- encoding : utf-8 -*-
require 'spec_helper'

describe AnalysisTask do
  
  describe "#valid?" do
    context "when no name is specified" do
      before(:each) do
        @task = FactoryGirl.build(:analysis_task, :name => nil)
      end
      
      it "isn't valid" do
        @task.should_not be_valid
      end
    end
    
    context "when no dataset is specified" do
      before(:each) do
        @task = FactoryGirl.build(:analysis_task, :dataset => nil)
      end
      
      it "isn't valid" do
        @task.should_not be_valid
      end
    end
    
    context "when no type is specified" do
      before(:each) do
        @task = FactoryGirl.build(:analysis_task, :job_type => nil)
      end
      
      it "isn't valid" do
        @task.should_not be_valid
      end
    end
    
    context "when dataset, type, and name are specified" do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task)
      end
      
      it "is valid" do
        @task.should be_valid
      end
    end
  end
  
  describe '#finished_at' do
    context "when newly created" do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task)
      end
      
      it "isn't set" do
        @task.finished_at.should be_nil
      end
    end
  end
  
  describe '#failed' do
    context "when newly created" do
      before(:each) do
        @task = FactoryGirl.create(:analysis_task)
      end
      
      it "is false" do
        @task.finished_at.should be_false
      end
    end
  end
  
  def create_task_with_file
    @task = FactoryGirl.create(:analysis_task)
    @task.result_file = Download.create_file('test.txt') do |file|
      file.write 'test'
    end
    @task.save

    @filename = @task.result_file.filename
  end
  
  describe "#result_file" do
    context "when a file is created" do
      before(:each) do
        create_task_with_file
      end
      
      after(:each) do
        @task.destroy
      end
      
      it "creates the file" do
        File.exists?(@filename).should be_true
      end
      
      it "points to the right file" do
        IO.read(@filename).should eq('test')
      end
    end
  end
  
  describe "#destroy" do
    context "when there is an associated file" do
      before(:each) do
        create_task_with_file
        @task.destroy
      end
      
      it "deletes the file" do
        File.exists?(@filename).should be_false
      end
    end
  end
  
end
