# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::WordFrequency do
  
  it_should_behave_like 'an analysis job'

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, :entries_count => 10,
                                  :working => true, :user => @user)
  end

  after(:each) do
    @dataset.analysis_tasks[0].destroy unless @dataset.analysis_tasks[0].nil?
  end
  
  describe "#valid?" do
    context "when all parameters are valid" do
      before(:each) do        
        Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :block_size => 100,
                                          :split_across => true,
                                          :num_words => 0).perform

        @output = CSV.read(@dataset.analysis_tasks[0].result_file.filename)
      end
      
      it 'names the task correctly' do
        @dataset.analysis_tasks[0].name.should eq("Word frequency list")
      end
      
      it 'creates good CSV' do
        @output.should be_an(Array)
      end
    end
  end
end

