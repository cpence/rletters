# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Analysis::Frequency::FromTF do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 10, working: true,
                                     user: @user)
  end

  describe '#num_words' do
    context 'without num_words set' do
      before(:example) do
        @analyzer = described_class.new(@dataset)
      end

      it 'includes all words' do
        expect(@analyzer.block_stats[0][:types]).to eq(@analyzer.blocks[0].size)
      end

      it 'saves blocks' do
        expect(@analyzer.blocks).to be_an(Array)
        expect(@analyzer.blocks[0]).to be_a(Hash)
        expect(@analyzer.blocks[0].first[0]).to be_a(String)
        expect(@analyzer.blocks[0].first[1]).to be_an(Integer)

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
      before(:example) do
        @analyzer = described_class.new(@dataset, nil, num_words: -1)
      end

      it 'acts like it was not set at all' do
        expect(@analyzer.block_stats[0][:types]).to eq(@analyzer.blocks[0].size)
      end
    end

    context 'with num_words set to 10' do
      before(:example) do
        @analyzer = described_class.new(@dataset, nil, num_words: 10)
      end

      it 'only includes ten words' do
        @analyzer.blocks.each do |b|
          expect(b.size).to eq(10)
        end
      end
    end
  end

  describe '#split_across' do
    before(:example) do
      @analyzer = described_class.new(@dataset)
    end

    it 'includes all words in all blocks' do
      @analyzer.blocks.each do |b|
        expect(b.size).to eq(@analyzer.blocks[0].size)
      end

      expect(@analyzer.num_dataset_types).to eq(@analyzer.blocks[0].size)
    end
  end

  describe '#inclusion_list' do
    before(:example) do
      @analyzer = described_class.new(@dataset, nil, inclusion_list: 'blackwell stiver')
    end

    it 'only includes those words' do
      expect(@analyzer.blocks[0].keys).to match_array(%w(blackwell stiver))
    end
  end

  describe '#exclusion_list' do
    before(:example) do
      @analyzer = described_class.new(@dataset, nil, exclusion_list: 'a the')
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
    before(:example) do
      @list = create(:stop_list)
      @analyzer = described_class.new(@dataset, nil, stop_list: @list)
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
    before(:example) do
      @analyzer = described_class.new(@dataset)
    end

    it 'includes name, types, and tokens' do
      expect(@analyzer.block_stats[0][:name]).to be
      expect(@analyzer.block_stats[0][:types]).to be
      expect(@analyzer.block_stats[0][:tokens]).to be
    end
  end

  describe '#word_list' do
    before(:example) do
      @analyzer = described_class.new(@dataset, nil, num_words: 10)
    end

    it 'only includes the requested number of words' do
      expect(@analyzer.word_list.size).to eq(10)
    end

    it 'analyzes those words in the blocks' do
      @analyzer.word_list.each do |w|
        expect(@analyzer.blocks[0][w]).to be
      end
    end
  end

  describe '#tf_in_dataset' do
    before(:example) do
      @analyzer = described_class.new(@dataset)
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

  describe '#df_in_dataset' do
    before(:example) do
      @analyzer = described_class.new(@dataset)
    end

    it 'includes (at least) all the words in the list' do
      @analyzer.word_list.each do |w|
        expect(@analyzer.df_in_dataset[w]).to be
      end
    end

    it 'returns correct values for every word' do
      expect(@analyzer.df_in_dataset['blackwell']).to eq(4)
      expect(@analyzer.df_in_dataset['anthropology']).to eq(1)
    end
  end

  describe '#df_in_corpus' do
    before(:example) do
      @analyzer = described_class.new(@dataset)
    end

    it 'includes (at least) all the words in the list' do
      @analyzer.word_list.each do |w|
        expect(@analyzer.df_in_corpus[w]).to be
      end
    end

    it 'returns correct values' do
      expect(@analyzer.df_in_corpus['blackwell']).to eq(573)
      expect(@analyzer.df_in_corpus['anthropology']).to eq(4)
    end
  end

  describe 'progress reporting' do
    it 'calls the progress function with under and equal to 100' do
      called_sub_100 = false
      called_100 = false

      described_class.new(@dataset, ->(p) {
        if p < 100
          called_sub_100 = true
        else
          called_100 = true
        end
      })

      expect(called_sub_100).to be true
      expect(called_100).to be true
    end
  end
end
