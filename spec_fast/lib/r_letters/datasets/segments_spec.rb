# -*- encoding : utf-8 -*-
require 'core_ext/hash/compact'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/array/grouping'

require 'r_letters/documents/word_list'
require 'r_letters/documents/segmenter'
require 'r_letters/datasets/segments'
require 'support/doubles/dataset_fulltext'

describe RLetters::Datasets::Segments do
  before(:each) do
    @dataset = double_dataset_fulltext
  end

  context 'one block for the dataset, splitting across' do
    before(:each) do
      @segments = RLetters::Datasets::Segments.new(@dataset).segments
    end

    it 'creates only one block' do
      expect(@segments.count).to eq(1)
    end

    it 'puts all the words in the block' do
      expect(@segments[0].words.count).to eq(238)
    end

    it 'names the block' do
      expect(@segments[0].name).to eq('Block #1/1')
    end
  end

  context 'one block per document, not splitting across' do
    before(:each) do
      @segments = RLetters::Datasets::Segments.new(@dataset, nil, split_across: false).segments
    end

      it 'creates two blocks' do
        expect(@segments.count).to eq(2)
      end

      it 'puts all the words in each block' do
        expect(@segments[0].words.count).to eq(119)
        expect(@segments[1].words.count).to eq(119)
      end

      it 'names the blocks' do
        expect(@segments[0].name).to eq('Block #1/1 (within document doi:10.1234/5678)')
        expect(@segments[1].name).to eq('Block #1/1 (within document doi:10.2345/6789)')
      end
  end

  context 'four total blocks, splitting across' do
    before(:each) do
      @doc_segmenter = RLetters::Documents::Segmenter.new(nil, num_blocks: 4)
      @segments = RLetters::Datasets::Segments.new(@dataset, @doc_segmenter).segments
    end

    it 'creates four blocks' do
      expect(@segments.count).to eq(4)
    end

    it 'splits the words evenly' do
      expect(@segments.map(&:words).map(&:count)).to match_array([59, 59, 60, 60])
    end

    it 'names the blocks' do
      expect(@segments[0].name).to eq('Block #1/4')
    end
  end

  context 'truncate_all, splitting across' do
    before(:each) do
      @doc_segmenter = RLetters::Documents::Segmenter.new(nil, block_size: 10,
                                                               last_block: :truncate_all)
      @segments = RLetters::Datasets::Segments.new(@dataset, @doc_segmenter).segments
    end

    it 'creates only one block' do
      expect(@segments.count).to eq(1)
    end

    it 'puts ten words in the block' do
      expect(@segments[0].words.count).to eq(10)
    end

    it 'names the block' do
      expect(@segments[0].name).to eq('Block #1 of 10 words')
    end
  end

  context 'truncate_all, not splitting across' do
    before(:each) do
      @doc_segmenter = RLetters::Documents::Segmenter.new(nil, block_size: 10,
                                                               last_block: :truncate_all)
      @segments = RLetters::Datasets::Segments.new(@dataset,
                                                   @doc_segmenter,
                                                   split_across: false).segments
    end

    it 'creates two blocks' do
      expect(@segments.count).to eq(2)
    end

    it 'puts ten words in each block' do
      expect(@segments[0].words.count).to eq(10)
      expect(@segments[1].words.count).to eq(10)
    end

    it 'names the blocks' do
      expect(@segments[0].name).to eq('Block #1 of 10 words (within document doi:10.1234/5678)')
      expect(@segments[1].name).to eq('Block #1 of 10 words (within document doi:10.2345/6789)')
    end
  end
end
