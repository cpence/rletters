# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Dataset do
  
  describe '#valid?' do
    context 'when name is not specified' do
      before(:each) do
        @dataset = FactoryGirl.build(:dataset, :name => nil)
      end
      
      it "isn't valid" do
        @dataset.should_not be_valid
      end
    end
    
    context 'when user is not specified' do
      before(:each) do
        @dataset = FactoryGirl.build(:dataset, :user => nil)
      end
      
      it "isn't valid" do
        @dataset.should_not be_valid
      end
    end
    
    context 'when user and name are specified' do
      before (:each) do
        @dataset = FactoryGirl.create(:dataset)
      end
      
      it "is valid" do
        @dataset.should be_valid
      end
    end
  end
  
  describe '#analysis_tasks' do
    context 'when an analysis task is created' do
      before(:each) do
        @dataset = FactoryGirl.create(:dataset)
        @task = FactoryGirl.create(:analysis_task, :dataset => @dataset, :name => 'test')
      end
      
      after(:each) do
        @task.destroy
        @dataset.destroy
      end
      
      it "has one analysis task" do
        @dataset.analysis_tasks.should have(1).items
      end
      
      it "points to the right analysis task" do
        @dataset.analysis_tasks[0].name.should eq('test')
      end
    end
  end
  
  describe '#entries' do
    context 'when creating a new dataset' do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @dataset = FactoryGirl.create(:full_dataset, :user => @user, :entries_count => 2)
      end
      
      it "is connected to the user" do
        @user.datasets.reload
        @user.datasets.should have(1).items
      end
      
      it "has the right number of entries" do
        @dataset.entries.should have(2).items
      end
    end
  end
end
