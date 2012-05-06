# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::SingleTermVectors do
  
  it_should_behave_like 'an analysis job with a file' do
    let(:dataset_params) { { :entries_count => 1 } }
  end
  
  context "with a multi-document dataset" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @dataset = FactoryGirl.create(:full_dataset, :working => true, :user => @user)
    end
    
    it "raises an exception" do
      expect {
        Jobs::Analysis::SingleTermVectors.new(:user_id => @user.to_param,
                                              :dataset_id => @dataset.to_param).perform
      }.to raise_error(ArgumentError)
    end
  end

  context "when all parameters are valid" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @dataset = FactoryGirl.create(:full_dataset, :entries_count => 1,
                                    :working => true, :user => @user)
      
      Jobs::Analysis::SingleTermVectors.new(:user_id => @user.to_param,
                                            :dataset_id => @dataset.to_param).perform
    end
    
    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end
    
    it 'names the task correctly' do
      @dataset.analysis_tasks[0].name.should eq("Term frequency information")
    end
    
    it 'creates good YAML' do
      tv = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      tv.should be_a(Hash)
    end
  end
end
