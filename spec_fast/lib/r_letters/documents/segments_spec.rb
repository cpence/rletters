# -*- encoding : utf-8 -*-
require 'core_ext/hash/compact'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/array/grouping'

require 'r_letters/documents/word_list'
require 'r_letters/documents/segments'
require 'support/doubles/document_fulltext'

describe RLetters::Documents::Segments do
  before(:each) do
    @doc = stub_document_fulltext
    @word_list = RLetters::Documents::WordList.new
  end

  context 'with no options' do
    before(:each) do
      @segmenter = described_class.new(@list)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates one block' do
      expect(@blocks.count).to eq(1)
    end

    it 'names the block' do
      expect(@blocks[0].name).to eq('Block #1/1')
    end

    it 'puts all the words in the block' do
      expect(@blocks[0].words.count).to eq(119)
      expect(@blocks[0].words.take(6)).to eq(['it', 'was', 'the', 'best', 'of', 'times'])
    end
  end

  context 'with a single block' do
    before(:each) do
      @segmenter = described_class.new(@list, num_blocks: 1)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates one block' do
      expect(@blocks.count).to eq(1)
    end

    it 'names the block' do
      expect(@blocks[0].name).to eq('Block #1/1')
    end

    it 'puts all the words in the block' do
      expect(@blocks[0].words.count).to eq(119)
      expect(@blocks[0].words.take(6)).to eq(['it', 'was', 'the', 'best', 'of', 'times'])
    end
  end

  context 'with multiple blocks' do
    before(:each) do
      @segmenter = described_class.new(@list, num_blocks: 5)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates five blocks' do
      expect(@blocks.count).to eq(5)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1/5')
    end

    it 'gives the blocks the right sizes' do
      expect(@blocks.map(&:words).map(&:count)).to match_array([24, 24, 24, 24, 23])
    end
  end

  context 'with word-size blocks, big_last' do
    before(:each) do
      @segmenter = described_class.new(@list, block_size: 3,
                                              last_block: :big_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates 39 blocks' do
      expect(@blocks.count).to eq(39)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(['it', 'was', 'the'])
    end

    it 'makes a big last block' do
      expect(@blocks.last.words).to eq(['superlative', 'degree', 'of', 'comparison', 'only'])
    end
  end

  context 'with word-size blocks, small_last' do
    before(:each) do
      @segmenter = described_class.new(@list, block_size: 3,
                                              last_block: :small_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates 40 blocks' do
      expect(@blocks.count).to eq(40)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(['it', 'was', 'the'])
    end

    it 'makes a small last block' do
      expect(@blocks.last.words).to eq(['comparison', 'only'])
    end
  end

  context 'with word-size blocks, truncate_last' do
    before(:each) do
      @segmenter = described_class.new(@list, block_size: 3,
                                              last_block: :truncate_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates 39 blocks' do
      expect(@blocks.count).to eq(39)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(['it', 'was', 'the'])
    end

    it 'truncates leftover words' do
      expect(@blocks.last.words).to eq(['superlative', 'degree', 'of'])
    end
  end

  context 'with word-size blocks, truncate_all' do
    before(:each) do
      @segmenter = described_class.new(@list, block_size: 3,
                                              last_block: :truncate_all)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates 1 block' do
      expect(@blocks.count).to eq(1)
    end

    it 'names the block' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes a single sized block' do
      expect(@blocks.first.words).to eq(['it', 'was', 'the'])
    end
  end

  describe '#reset!' do
    it 'resets all the parameters' do
      segmenter = described_class.new(@list)
      segmenter.add(@doc.uid)
      blocks = segmenter.blocks

      segmenter.reset!
      new_blocks = segmenter.blocks

      expect(new_blocks).to be_empty
    end
  end
end
