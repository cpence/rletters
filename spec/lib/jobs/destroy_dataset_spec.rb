# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::DestroyDataset do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:dataset, :user => @user)
  end
  
  context "when the wrong user is specified" do
    it "raises an exception and does not destroy a dataset" do      
      expect {
        expect {
          Jobs::DestroyDataset.new(:user_id => FactoryGirl.create(:user).to_param, 
                                   :dataset_id => @dataset.to_param).perform
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.to_not change{@user.datasets.count}
    end
  end
  
  context "when an invalid user is specified" do
    it "raises an exception" do
      expect {
        Jobs::DestroyDataset.new(:user_id => '123123123123123', 
                                 :dataset_id => @dataset.to_param).perform
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
  context "when an invalid dataset is specified" do
    it "raises an exception and does not destroy a dataset" do
      expect {
        expect {
          Jobs::DestroyDataset.new(:user_id => @user.to_param, 
                                   :dataset_id => '123123123123').perform
        }.to raise_error(ActiveRecord::RecordNotFound)
      }.to_not change{@user.datasets.count}
    end
  end
  
  context "when the parameters are valid" do
    it "destroys a dataset" do
      expect {
        Jobs::DestroyDataset.new(:user_id => @user.to_param, 
                                 :dataset_id => @dataset.to_param).perform
      }.to change{@user.datasets.count}.by(-1)
    end
  end
  
end
