# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WordFrequencyAnalyzer do
  
  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, :entries_count => 10,
                                  :working => true, :user => @user)
  end

  describe "#initialize" do
    context "with both num_blocks and block_size set" do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              :block_size => 10,
                                              :num_blocks => 30,
                                              :split_across => true,
                                              :num_words => 0)
      end

      it 'acts like only block_size was set' do
        num = @analyzer.block_stats.count - 1
        @analyzer.block_stats.take(num).each do |s|
          s[:tokens].should eq(10)
        end
      end        
    end
    
    context "with neither num_blocks nor block_size set" do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              :split_across => true,
                                              :num_words => 0)
      end
      
      it 'just makes one block, splitting across' do
        @analyzer.block_stats.count.should eq(1)
      end
    end
  end        
  
  describe "#block_size" do
    context "with 10-word blocks, split across" do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              :block_size => 10,
                                              :split_across => true,
                                              :num_words => 0)
      end
      
      it 'saves blocks and stats' do
        @analyzer.blocks.should be_an(Array)
        @analyzer.blocks[0].should be_a(Hash)

        @analyzer.block_stats.should be_an(Array)
        @analyzer.block_stats[0].should be_a(Hash)
        @analyzer.block_stats[0][:name].should be
        @analyzer.block_stats[0][:types].should be
        @analyzer.block_stats[0][:tokens].should be

        @analyzer.num_dataset_types.should be
        @analyzer.num_dataset_tokens.should be
      end
      
      it 'creates 10 word blocks, except maybe the last one' do
        num = @analyzer.block_stats.count - 1
        @analyzer.block_stats.take(num).each do |s|
          s[:tokens].should eq(10)
        end
      end

      it 'creates a parallel list (same words in all blocks)' do
        words = @analyzer.blocks[0].keys
        @analyzer.blocks.each do |b|
          b.keys.should eq(words)
        end
      end
    end

    context "with 100k-word blocks, not split across" do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              :block_size => 100000,
                                              :split_across => false)
      end

      it 'makes 10 blocks (the size of the dataset)' do
        @analyzer.blocks.should have(10).blocks
      end
    end
  end

  describe "#num_blocks" do
    context "with 10 blocks, split across" do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              :num_blocks => 10,
                                              :split_across => true,
                                              :num_words => 0)
      end
      
      it 'creates 10 blocks' do
        @analyzer.blocks.count.should eq(10)
      end
      
      it 'creates all blocks nearly the same size' do
        size = @analyzer.block_stats[0][:tokens]
        @analyzer.block_stats.each do |s|
          s[:tokens].should be_within(1).of(size)
        end
      end
    end

    context "with 3 blocks per document, not split across" do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              :num_blocks => 3,
                                              :split_across => false,
                                              :num_words => 0)
      end
      
      it 'creates at least 30 blocks' do
        @analyzer.blocks.should have_at_least(30).blocks
      end
      
      it 'creates all blocks nearly the same size for each document' do
        size = @analyzer.block_stats[0][:tokens]
        doc = @analyzer.block_stats[0][:name].match(/.*(\(within .*\))/)
        
        @analyzer.block_stats.each do |s|
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
        @analyzer = WordFrequencyAnalyzer.new(@dataset)
      end
      
      it 'includes all words' do
        @analyzer.block_stats[0][:types].should eq(@analyzer.blocks[0].count)
      end

      it 'is the same as the dataset stats' do
        @analyzer.block_stats[0][:types].should eq(@analyzer.num_dataset_types)
        @analyzer.block_stats[0][:tokens].should eq(@analyzer.num_dataset_tokens)
      end
    end

    context "with num_words set to 10" do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              :split_across => true,
                                              :num_words => 10)
      end

      it 'only includes ten words' do
        @analyzer.blocks.each do |b|
          b.count.should eq(10)
        end
      end
    end      
  end

  describe "#block_stats" do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset)
    end

    it 'includes name, types, and tokens' do
      @analyzer.block_stats[0][:name].should be
      @analyzer.block_stats[0][:types].should be
      @analyzer.block_stats[0][:tokens].should be
    end
  end

  describe "#word_list" do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                            :num_words => 10)
    end

    it "only includes the requested number of words" do
      @analyzer.word_list.should have(10).words
    end

    it "analyzes those words in the blocks" do
      @analyzer.word_list.each do |w|
        @analyzer.blocks[0][w].should be
      end
    end
  end

  describe "#tf_in_dataset" do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset)
    end

    it "includes (at least) all the words in the list" do
      @analyzer.word_list.each do |w|
        @analyzer.tf_in_dataset[w].should be
      end
    end

    it "returns the same values as a single-block analysis" do
      @analyzer.word_list.each do |w|
        @analyzer.blocks[0][w].should eq(@analyzer.tf_in_dataset[w])
      end
    end
  end
end

