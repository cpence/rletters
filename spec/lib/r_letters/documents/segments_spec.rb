# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Segments do
  before(:example) do
    @doc = build(:full_document)
    @word_list = RLetters::Documents::WordList.new
  end

  context 'with no options' do
    before(:example) do
      @segmenter = described_class.new(@list)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates one block' do
      expect(@blocks.size).to eq(1)
    end

    it 'names the block' do
      expect(@blocks[0].name).to eq('Block #1/1')
    end

    it 'puts all the words in the block' do
      expect(@blocks[0].words.size).to eq(29)
      expect(@blocks[0].words.take(6)).to eq(['ethology', 'how', 'reliable', 'are', 'the', 'methods'])
    end
  end

  context 'with a single block' do
    before(:example) do
      @segmenter = described_class.new(@list, num_blocks: 1)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates one block' do
      expect(@blocks.size).to eq(1)
    end

    it 'names the block' do
      expect(@blocks[0].name).to eq('Block #1/1')
    end

    it 'puts all the words in the block' do
      expect(@blocks[0].words.size).to eq(29)
      expect(@blocks[0].words.take(6)).to eq(['ethology', 'how', 'reliable', 'are', 'the', 'methods'])
    end

    it 'sets the words_for_last correctly' do
      expect(@segmenter.words_for_last).to include('repertoire')
      expect(@segmenter.words_for_last).to include('ethology')
    end
  end

  context 'with multiple blocks' do
    before(:example) do
      @segmenter = described_class.new(@list, num_blocks: 5)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates five blocks' do
      expect(@blocks.size).to eq(5)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1/5')
    end

    it 'gives the blocks the right sizes' do
      expect(@blocks.map(&:words).map(&:size)).to match_array([6, 6, 6, 6, 5])
    end

    it 'still sets the words_for_last correctly' do
      expect(@segmenter.words_for_last).to include('repertoire')
      expect(@segmenter.words_for_last).to include('ethology')
    end
  end

  context 'with word-size blocks, big_last' do
    before(:example) do
      @segmenter = described_class.new(@list, block_size: 3,
                                              last_block: :big_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates 9 blocks' do
      expect(@blocks.size).to eq(9)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(['ethology', 'how', 'reliable'])
    end

    it 'makes a big last block' do
      expect(@blocks.last.words.count).to eq(5)
    end
  end

  context 'with word-size blocks, small_last' do
    before(:example) do
      @segmenter = described_class.new(@list, block_size: 3,
                                              last_block: :small_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates 10 blocks' do
      expect(@blocks.size).to eq(10)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(['ethology', 'how', 'reliable'])
    end

    it 'makes a small last block' do\
      expect(@blocks.last.words.count).to eq(2)
    end
  end

  context 'with word-size blocks, truncate_last' do
    before(:example) do
      @segmenter = described_class.new(@list, block_size: 3,
                                              last_block: :truncate_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates 9 blocks' do
      expect(@blocks.size).to eq(9)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(['ethology', 'how', 'reliable'])
    end

    it 'truncates leftover words' do
      expect(@blocks.last.words.count).to eq(3)
    end
  end

  context 'with word-size blocks, truncate_all' do
    before(:example) do
      @segmenter = described_class.new(@list, block_size: 3,
                                              last_block: :truncate_all)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates 1 block' do
      expect(@blocks.size).to eq(1)
    end

    it 'names the block' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes a single sized block' do
      expect(@blocks.first.words).to eq(['ethology', 'how', 'reliable'])
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
