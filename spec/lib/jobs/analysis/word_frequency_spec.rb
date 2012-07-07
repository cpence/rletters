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

        @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      end
      
      it 'names the task correctly' do
        @dataset.analysis_tasks[0].name.should eq("Word frequency list")
      end
      
      it 'creates good YAML' do
        @output.should be_a(Hash)
      end
    end

    context "with both num_blocks and block_size set" do
      before(:each) do
        Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :block_size => 10,
                                          :num_blocks => 30,
                                          :split_across => true,
                                          :num_words => 0).perform
        
        @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      end

      it 'acts like only block_size was set' do
        num = @output[:block_stats].count - 1
        @output[:block_stats].take(num).each do |s|
          s[:tokens].should eq(10)
        end
      end        
    end
  end

  context "with neither num_blocks nor block_size set" do
    before(:each) do
      Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                        :dataset_id => @dataset.to_param,
                                        :split_across => true,
                                        :num_words => 0).perform
      
      @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
    end
    
    after(:each) do
      @dataset.analysis_tasks[0].destroy
    end
    
    it 'just makes one block, splitting across' do
      @output[:block_stats].count.should eq(1)
    end
  end        
  
  describe "#block_size" do
    context "with 10-word blocks, split across" do
      before(:each) do
        Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :block_size => 10,
                                          :split_across => true,
                                          :num_words => 0).perform
        
        @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      end
      
      after(:each) do
        @dataset.analysis_tasks[0].destroy
      end
      
      it 'saves blocks and stats' do
        @output[:blocks].should be_an(Array)
        @output[:blocks][0].should be_a(Hash)

        @output[:block_stats].should be_an(Array)
        @output[:block_stats][0].should be_a(Hash)
        @output[:block_stats][0][:name].should be
        @output[:block_stats][0][:types].should be
        @output[:block_stats][0][:tokens].should be
        
        @output[:dataset_stats].should be_a(Hash)
        @output[:dataset_stats][:types].should be
        @output[:dataset_stats][:tokens].should be
      end
      
      it 'creates 10 word blocks, except maybe the last one' do
        num = @output[:block_stats].count - 1
        @output[:block_stats].take(num).each do |s|
          s[:tokens].should eq(10)
        end
      end

      it 'creates a parallel list (same words in all blocks)' do
        words = @output[:blocks][0].keys
        @output[:blocks].each do |b|
          b.keys.should eq(words)
        end
      end
    end

    context "with 100k-word blocks, not split across" do
      before(:each) do
        Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :block_size => 100000,
                                          :split_across => false).perform
        
        @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      end
      
      after(:each) do
        @dataset.analysis_tasks[0].destroy
      end

      it 'makes 10 blocks (the size of the dataset)' do
        @output[:blocks].should have(10).blocks
      end
    end
  end

  describe "#num_blocks" do
    context "with 10 blocks, split across" do
      before(:each) do
        Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :num_blocks => 10,
                                          :split_across => true,
                                          :num_words => 0).perform
        
        @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      end
      
      after(:each) do
        @dataset.analysis_tasks[0].destroy
      end
      
      it 'creates 10 blocks' do
        @output[:blocks].count.should eq(10)
      end
      
      it 'creates all blocks nearly the same size' do
        size = @output[:block_stats][0][:tokens]
        @output[:block_stats].each do |s|
          s[:tokens].should be_within(1).of(size)
        end
      end
    end

    context "with 3 blocks per document, not split across" do
      before(:each) do
        Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :num_blocks => 3,
                                          :split_across => false,
                                          :num_words => 0).perform
        
        @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      end
      
      after(:each) do
        @dataset.analysis_tasks[0].destroy
      end
      
      it 'creates at least 30 blocks' do
        @output[:blocks].should have_at_least(30).blocks
      end
      
      it 'creates all blocks nearly the same size for each document' do
        size = @output[:block_stats][0][:tokens]
        doc = @output[:block_stats][0][:name].match(/.*(\(within .*\))/)
        
        @output[:block_stats].each do |s|
          this_doc = s[:name].match(/.*(\(within .*\))/)[1]
          if this_doc != doc
            size = s[:tokens]
            doc = this_doc
          end
          
          s[:tokens].should be_within(1).of(size)
        end
      end
    end
  end

  describe "#num_words" do
    context "without num_words set" do
      before(:each) do
        Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :split_across => true).perform
        
        @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      end
      
      after(:each) do
        @dataset.analysis_tasks[0].destroy
      end
      
      it 'includes all words' do
        @output[:block_stats][0][:types].should eq(@output[:blocks][0].count)
      end

      it 'is the same as the dataset stats' do
        @output[:block_stats][0][:types].should eq(@output[:dataset_stats][:types])
        @output[:block_stats][0][:tokens].should eq(@output[:dataset_stats][:tokens])
      end
    end

    context "with num_words set to 10" do
      before(:each) do
        Jobs::Analysis::WordFrequency.new(:user_id => @user.to_param,
                                          :dataset_id => @dataset.to_param,
                                          :split_across => true,
                                          :num_words => 10).perform
        
        @output = YAML.load_file(@dataset.analysis_tasks[0].result_file.filename)
      end
      
      after(:each) do
        @dataset.analysis_tasks[0].destroy
      end

      it 'only includes ten words' do
        @output[:blocks].each do |b|
          b.count.should eq(10)
        end
      end
    end      
  end
end

