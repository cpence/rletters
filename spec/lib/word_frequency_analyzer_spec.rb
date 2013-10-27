# -*- encoding : utf-8 -*-
require 'spec_helper'

describe WordFrequencyAnalyzer,
         vcr: { cassette_name: 'solr_single_fulltext' } do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, entries_count: 10,
                                                 working: true, user: @user)
  end

  describe '#initialize' do
    context 'with both num_blocks and block_size set' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              block_size: 10,
                                              num_blocks: 30,
                                              split_across: true,
                                              num_words: 0)
      end

      it 'acts like only block_size was set' do
        num = @analyzer.block_stats.count - 1
        @analyzer.block_stats.take(num).each do |s|
          expect(s[:tokens]).to eq(10)
        end
      end
    end

    context 'with neither num_blocks nor block_size set' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              split_across: true,
                                              num_words: 0)
      end

      it 'just makes one block, splitting across' do
        expect(@analyzer.block_stats.count).to eq(1)
      end
    end
  end

  describe '#block_size' do
    context 'with 10-word blocks, split across' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              block_size: 10,
                                              split_across: true,
                                              num_words: 0)
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

      it 'creates 10 word blocks, and a big last block (default to big_last)' do
        num = @analyzer.block_stats.count - 1
        @analyzer.block_stats.take(num).each do |s|
          expect(s[:tokens]).to eq(10)
        end
        expect(@analyzer.block_stats.last[:tokens]).to be > 10
      end

      it 'creates a parallel list (same words in all blocks)' do
        words = @analyzer.blocks[0].keys
        @analyzer.blocks.each do |b|
          expect(b.keys).to eq(words)
        end
      end
    end

    context 'with 10-word blocks, split across, small_last' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              block_size: 10,
                                              split_across: true,
                                              num_words: 0,
                                              last_block: :small_last)
      end

      it 'creates 10-word blocks, and a small last block' do
        num = @analyzer.block_stats.count - 1
        @analyzer.block_stats.take(num).each do |s|
          expect(s[:tokens]).to eq(10)
        end
        expect(@analyzer.block_stats.last[:tokens]).to be < 10
      end
    end

    context 'with 10-word blocks, split across, truncate_last' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              block_size: 10,
                                              split_across: true,
                                              num_words: 0,
                                              last_block: :truncate_last)
      end

      it 'creates 10-word blocks only' do
        @analyzer.block_stats.each do |s|
          expect(s[:tokens]).to eq(10)
        end
      end
    end

    context 'with 10-word blocks, split across, truncate_all' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              block_size: 10,
                                              split_across: true,
                                              num_words: 0,
                                              last_block: :truncate_all)
      end

      it 'creates only one 10-word block' do
        expect(@analyzer.block_stats).to have(1).entry
        expect(@analyzer.block_stats[0][:tokens]).to eq(10)
      end
    end

    context 'with 10-word blocks, not split across, truncate_all' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              block_size: 10,
                                              split_across: false,
                                              num_words: 0,
                                              last_block: :truncate_all)
      end

      it 'creates one 10-word block for each document' do
        expect(@analyzer.block_stats).to have(10).entries
        @analyzer.block_stats.each do |s|
          expect(s[:tokens]).to eq(10)
        end
      end
    end

    context 'with 100k-word blocks, not split across' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              block_size: 100_000,
                                              split_across: false)
      end

      it 'makes 10 blocks (the size of the dataset)' do
        expect(@analyzer.blocks).to have(10).blocks
      end
    end
  end

  describe '#num_blocks' do
    context 'with 10 blocks, split across' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              num_blocks: 10,
                                              split_across: true,
                                              num_words: 0)
      end

      it 'creates 10 blocks' do
        expect(@analyzer.blocks.count).to eq(10)
      end

      it 'creates all blocks nearly the same size' do
        size = @analyzer.block_stats[0][:tokens]
        @analyzer.block_stats.each do |s|
          expect(s[:tokens]).to be_within(1).of(size)
        end
      end
    end

    context 'with 3 blocks per document, not split across' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset,
                                              num_blocks: 3,
                                              split_across: false,
                                              num_words: 0)
      end

      it 'creates at least 30 blocks' do
        expect(@analyzer.blocks).to have_at_least(30).blocks
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

          expect(s[:tokens]).to be_within(1).of(size)
        end
      end
    end
  end

  describe '#num_words' do
    context 'without num_words set' do
      before(:each) do
        @analyzer = WordFrequencyAnalyzer.new(@dataset)
      end

      it 'includes all words' do
        expect(@analyzer.block_stats[0][:types]).to eq(@analyzer.blocks[0].count)
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

  describe '#inclusion_list' do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset, inclusion_list: 'a the')
    end

    it 'only includes those words' do
      expect(@analyzer.blocks[0].keys).to match_array(['a', 'the'])
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
      @list = StopList.find_by!(language: 'en')
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
      expect(@analyzer.word_list).to have(10).words
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

  describe '#num_corpus_documents' do
    before(:each) do
      @analyzer = WordFrequencyAnalyzer.new(@dataset)
    end

    it 'works' do
      expect(@analyzer.num_corpus_documents).to eq(1042)
    end
  end
end
