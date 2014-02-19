# -*- encoding : utf-8 -*-
require 'core_ext/hash/compact'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/array/grouping'

require 'r_letters/documents/word_list'
require 'r_letters/documents/segments'
require 'r_letters/datasets/segments'
require 'support/doubles/dataset_fulltext'

describe RLetters::Datasets::Segments do
  before(:each) do
    @dataset = double_dataset_fulltext
  end

  context 'one block for the dataset, splitting across' do
    before(:each) do
      @analyzer = described_class.new(@dataset)
      @segments = @analyzer.segments
    end

    it 'creates only one block' do
      expect(@segments.size).to eq(1)
    end

    it 'puts all the words in the block' do
      expect(@segments[0].words.size).to eq(238)
    end

    it 'names the block' do
      expect(@segments[0].name).to eq('Block #1/1')
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['it']).to eq(2)
      expect(@analyzer.dfs['was']).to eq(2)
      expect(@analyzer.dfs['the']).to eq(2)
      expect(@analyzer.dfs['best']).to eq(2)
    end
  end

  context 'progress reporting' do
    it 'calls the progress function with under and equal to 100' do
      called_sub_100 = false
      called_100 = false

      segments = described_class.new(@dataset).segments(->(p) {
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

  context 'one block per document, not splitting across' do
    before(:each) do
      @analyzer = described_class.new(@dataset, nil, split_across: false)
      @segments = @analyzer.segments
    end

    it 'creates two blocks' do
      expect(@segments.size).to eq(2)
    end

    it 'puts all the words in each block' do
      expect(@segments[0].words.size).to eq(119)
      expect(@segments[1].words.size).to eq(119)
    end

    it 'names the blocks' do
      expect(@segments[0].name).to eq('Block #1/1 (within document doi:10.1234/5678)')
      expect(@segments[1].name).to eq('Block #1/1 (within document doi:10.2345/6789)')
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['it']).to eq(2)
      expect(@analyzer.dfs['was']).to eq(2)
      expect(@analyzer.dfs['the']).to eq(2)
      expect(@analyzer.dfs['best']).to eq(2)
    end
  end

  context 'four total blocks, splitting across' do
    before(:each) do
      @doc_segmenter = RLetters::Documents::Segments.new(nil, num_blocks: 4)
      @analyzer = described_class.new(@dataset, @doc_segmenter)
      @segments = @analyzer.segments
    end

    it 'creates four blocks' do
      expect(@segments.size).to eq(4)
    end

    it 'splits the words evenly' do
      expect(@segments.map(&:words).map(&:size)).to match_array([59, 59, 60, 60])
    end

    it 'names the blocks' do
      expect(@segments[0].name).to eq('Block #1/4')
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['it']).to eq(2)
      expect(@analyzer.dfs['was']).to eq(2)
      expect(@analyzer.dfs['the']).to eq(2)
      expect(@analyzer.dfs['best']).to eq(2)
    end
  end

  context 'truncate_all, splitting across' do
    before(:each) do
      @doc_segmenter = RLetters::Documents::Segments.new(nil, block_size: 10,
                                                              last_block: :truncate_all)
      @analyzer = described_class.new(@dataset, @doc_segmenter)
      @segments = @analyzer.segments
    end

    it 'creates only one block' do
      expect(@segments.size).to eq(1)
    end

    it 'puts ten words in the block' do
      expect(@segments[0].words.size).to eq(10)
    end

    it 'names the block' do
      expect(@segments[0].name).to eq('Block #1 of 10 words')
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['it']).to eq(2)
      expect(@analyzer.dfs['was']).to eq(2)
      expect(@analyzer.dfs['the']).to eq(2)
      expect(@analyzer.dfs['best']).to eq(2)
    end
  end

  context 'truncate_all, not splitting across' do
    before(:each) do
      @doc_segmenter = RLetters::Documents::Segments.new(nil, block_size: 10,
                                                              last_block: :truncate_all)
      @analyzer = described_class.new(@dataset,
                                      @doc_segmenter,
                                      split_across: false)
      @segments = @analyzer.segments
    end

    it 'creates two blocks' do
      expect(@segments.size).to eq(2)
    end

    it 'puts ten words in each block' do
      expect(@segments[0].words.size).to eq(10)
      expect(@segments[1].words.size).to eq(10)
    end

    it 'names the blocks' do
      expect(@segments[0].name).to eq('Block #1 of 10 words (within document doi:10.1234/5678)')
      expect(@segments[1].name).to eq('Block #1 of 10 words (within document doi:10.2345/6789)')
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['it']).to eq(2)
      expect(@analyzer.dfs['was']).to eq(2)
      expect(@analyzer.dfs['the']).to eq(2)
      expect(@analyzer.dfs['best']).to eq(2)
    end
  end
end
