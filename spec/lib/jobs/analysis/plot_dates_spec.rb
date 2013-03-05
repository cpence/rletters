# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::PlotDates do
  
  it_should_behave_like 'an analysis job with a file'
  
  context "when all parameters are valid" do
    
    before(:each) do
      @user = FactoryGirl.create(:user)
      @dataset = FactoryGirl.create(:full_dataset, :user => @user,
                                    :working => true, :entries_count => 10)
      Jobs::Analysis::PlotDates.new(:user_id => @user.to_param,
                                    :dataset_id => @dataset.to_param).perform
    end
    
    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end
    
    it 'names the task correctly' do
      @dataset.analysis_tasks[0].name.should eq("Plot dataset by date")
    end
    
    it 'creates good YAML' do
      arr = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      arr.should be_an(Array)
    end
    
    it 'fills in some values' do
      arr = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      (1990..2012).should cover(arr[0][0])
      (1..5).should cover(arr[0][1])
    end
  end
  
end
