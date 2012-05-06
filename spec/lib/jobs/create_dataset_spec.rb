# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::CreateDataset do

  before(:each) do
    @user = FactoryGirl.create(:user)
  end
  
  context "when user is invalid" do
    it "raises an exception" do
      expect {
        Jobs::CreateDataset.new(:user_id => '123123123123', 
          :name => 'Test Dataset', :q => '*:*', :fq => nil,
          :qt => 'precise').perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when Solr fails" do
    break_solr
    
    it "raises an exception" do
      expect {
        Jobs::CreateDataset.new(:user_id => @user.to_param,
          :name => 'Test Dataset', :q => '*:*', :fq => nil,
          :qt => 'precise').perform
      }.to raise_error
      
      @user.datasets.should have(0).items
    end
  end
  
  context "given a standard search" do
    before(:each) do
      Jobs::CreateDataset.new(:user_id => @user.to_param,
        :name => 'Short Test Dataset', :q => 'test', :fq => nil,
        :qt => 'standard').perform

      @user.datasets.reload
    end
    
    it "creates a dataset" do
      @user.datasets.should have(1).items
      @user.datasets[0].should be
    end
    
    it "puts the right number of items in the dataset" do
      @user.datasets[0].entries.should have_at_least(10).items
    end
  end
  
  context "given large Solr dataset" do
    before(:each) do
      Jobs::CreateDataset.new(:user_id => @user.to_param,
        :name => 'Long Dataset', :q => '*:*', :fq => nil,
        :qt => 'precise').perform

      @user.datasets.reload
    end
    
    it "creates a dataset" do
      @user.datasets.should have(1).items
      @user.datasets[0].should be
    end
    
    it "puts the right number of items in the dataset" do
      @user.datasets[0].entries.should have(1042).items
    end
  end
  
end
