# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WordFrequencyAnalyzer do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, entries_count: 10,
                                                 working: true, user: @user)
  end

  describe '#num_words' do
    context 'without num_words set' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset)
      end

      it 'includes all words' do
        expect(@analyzer.block_stats[0][:types]).to eq(@analyzer.blocks[0].count)
      end

      it 'saves blocks and stats' do
        expect(@analyzer.blocks).to be_an(Array)
        expect(@analyzer.blocks[0]).to be_a(Hash)

        expect(@analyzer.block_stats).to be_an(Array)
        expect(@analyzer.block_stats[0]).to be_a(Hash)
        expect(@analyzer.block_stats[0][:name]).to be
        expect(@analyzer.block_stats[0][:types]).to be
        expect(@analyzer.block_stats[0][:tokens]).to be

        expect(@analyzer.num_dataset_types).to be
        expect(@analyzer.num_dataset_tokens).to be
      end

      it 'creates a parallel list (same words in all blocks)' do
        @analyzer.blocks.each do |b|
          expect(b.keys & @analyzer.word_list).to eq(b.keys)
        end
      end

      it 'is the same as the dataset stats' do
        expect(@analyzer.block_stats[0][:types]).to eq(@analyzer.num_dataset_types)
        expect(@analyzer.block_stats[0][:tokens]).to eq(@analyzer.num_dataset_tokens)
      end
    end

    context 'with num_words negative' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset, num_words: -1)
      end

      it 'acts like it was not set at all' do
        expect(@analyzer.block_stats[0][:types]).to eq(@analyzer.blocks[0].count)
      end
    end

    context 'with num_words set to 10' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              split_across: true,
                                              num_words: 10)
      end

      it 'only includes ten words' do
        @analyzer.blocks.each do |b|
          expect(b.count).to eq(10)
        end
      end
    end
  end

  describe '#ngrams' do
    context 'with num_words set' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              ngrams: 3,
                                              num_words: 10)
      end

      it 'correctly combines ngrams' do
        expect(@analyzer.blocks[0].keys.uniq).to match_array(@analyzer.blocks[0].keys)
        expect(@analyzer.blocks[0].values.max).to be > 1
      end

      it 'only includes 10 trigrams' do
        expect(@analyzer.blocks[0].count).to eq(10)
      end
    end

    context 'with inclusion_list set' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              ngrams: 3,
                                              inclusion_list: 'brain')
      end

      it 'produces ngrams that all contain brain' do
        @analyzer.blocks[0].each do |k, v|
          expect(k).to include('brain')
        end
      end
    end

    context 'with exclusion_list set' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              ngrams: 3,
                                              exclusion_list: 'brain')
      end

      it 'produces ngrams that do not contain brain' do
        @analyzer.blocks[0].each do |k, v|
          expect(k).not_to include('brain')
        end
      end
    end
  end

  describe '#inclusion_list' do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset, inclusion_list: 'a the')
    end

    it 'only includes those words' do
      expect(@analyzer.blocks[0].keys).to match_array(%w(a the))
    end
  end

  describe '#exclusion_list' do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset, exclusion_list: 'a the')
    end

    it 'does not include those words' do
      expect(@analyzer.blocks[0].keys).not_to include('a')
      expect(@analyzer.blocks[0].keys).not_to include('the')
    end

    it 'includes some words' do
      expect(@analyzer.blocks[0].keys).not_to be_empty
    end
  end

  describe '#stop_list' do
    before(:each) do
      @list = Documents::StopList.find_by!(language: 'en')
      @analyzer = WordFrequencyAnalyzer.new(@dataset, stop_list: @list)
    end

    it 'does not include "a" and "the"' do
      expect(@analyzer.blocks[0].keys).not_to include('a')
      expect(@analyzer.blocks[0].keys).not_to include('the')
    end

    it 'includes some words' do
      expect(@analyzer.blocks[0].keys).not_to be_empty
    end
  end

  describe '#block_stats' do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset)
    end

    it 'includes name, types, and tokens' do
      expect(@analyzer.block_stats[0][:name]).to be
      expect(@analyzer.block_stats[0][:types]).to be
      expect(@analyzer.block_stats[0][:tokens]).to be
    end
  end

  describe '#word_list' do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                            num_words: 10)
    end

    it 'only includes  the requested number of words' do
      expect(@analyzer.word_list.count).to eq(10)
    end

    it 'analyzes those words in the blocks' do
      @analyzer.word_list.each do |w|
        expect(@analyzer.blocks[0][w]).to be
      end
    end
  end

  describe '#tf_in_dataset' do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset)
    end

    it 'includes (at least) all the words in the list' do
      @analyzer.word_list.each do |w|
        expect(@analyzer.tf_in_dataset[w]).to be
      end
    end

    it 'returns the same values as a single-block analysis' do
      @analyzer.word_list.each do |w|
        expect(@analyzer.blocks[0][w]).to eq(@analyzer.tf_in_dataset[w])
      end
    end
  end
end
