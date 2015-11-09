require 'rails_helper'

RSpec.describe RLetters::Documents::Segments do
  before(:example) do
    @doc = build(:full_document)
    allow(Document).to receive(:find_by!).and_return(@doc)
  end

  context 'with no options' do
    before(:example) do
      @segmenter = described_class.new
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
      expect(@blocks[0].words.size).to eq(@doc.fulltext.split.count)
      expect(@blocks[0].words.take(5)).to eq(%w(it was the best of))
    end

    it 'gets the corpus dfs' do
      expect(@segmenter.corpus_dfs['it']).to eq(1486)
    end
  end

  context 'with a single block' do
    before(:example) do
      @segmenter = described_class.new(num_blocks: 1)
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
      expect(@blocks[0].words.size).to eq(@doc.fulltext.split.size)
      expect(@blocks[0].words.take(5)).to eq(%w(it was the best of))
    end

    it 'sets the words_for_last correctly' do
      expect(@segmenter.words_for_last).to include('it')
      expect(@segmenter.words_for_last).to include('was')
    end

    it 'gets the corpus dfs' do
      expect(@segmenter.corpus_dfs['it']).to eq(1486)
    end
  end

  context 'with multiple blocks' do
    before(:example) do
      @segmenter = described_class.new(num_blocks: 5)
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
      expect(@blocks.map(&:words).map(&:size)).to match_array([24, 24, 24, 24, 23])
    end

    it 'still sets the words_for_last correctly' do
      expect(@segmenter.words_for_last).to include('it')
      expect(@segmenter.words_for_last).to include('was')
    end

    it 'gets the corpus dfs' do
      expect(@segmenter.corpus_dfs['it']).to eq(1486)
    end
  end

  context 'with word-size blocks, invalid last_block' do
    before(:example) do
      @segmenter = described_class.new(block_size: 3,
                                       last_block: :purple)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'acts like big_last' do
      expect(@blocks.size).to eq((@doc.fulltext.split.size.to_f / 3.0).floor)
    end
  end

  context 'with word-size blocks, big_last' do
    before(:example) do
      @segmenter = described_class.new(block_size: 3,
                                       last_block: :big_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates the right number of blocks' do
      expect(@blocks.size).to eq((@doc.fulltext.split.size.to_f / 3.0).floor)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(%w(it was the))
    end

    it 'makes a big last block' do
      expect(@blocks.last.words.count).to be > 3
    end

    it 'gets the corpus dfs' do
      expect(@segmenter.corpus_dfs['it']).to eq(1486)
    end
  end

  context 'with word-size blocks, small_last' do
    before(:example) do
      @segmenter = described_class.new(block_size: 3,
                                       last_block: :small_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates the right number of blocks' do
      expect(@blocks.size).to eq((@doc.fulltext.split.count / 3.0).ceil)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(%w(it was the))
    end

    it 'makes a small last block' do
      expect(@blocks.last.words.count).to be < 3
    end

    it 'gets the corpus dfs' do
      expect(@segmenter.corpus_dfs['it']).to eq(1486)
    end
  end

  context 'with word-size blocks, truncate_last' do
    before(:example) do
      @segmenter = described_class.new(block_size: 3,
                                       last_block: :truncate_last)
      @segmenter.add(@doc.uid)
      @blocks = @segmenter.blocks
    end

    it 'creates the right number of blocks' do
      expect(@blocks.size).to eq((@doc.fulltext.split.count / 3.0).floor)
    end

    it 'names the blocks' do
      expect(@blocks[0].name).to eq('Block #1 of 3 words')
    end

    it 'makes correctly sized early blocks' do
      expect(@blocks.first.words).to eq(%w(it was the))
    end

    it 'truncates leftover words' do
      expect(@blocks.last.words.count).to eq(3)
    end

    it 'gets the corpus dfs' do
      expect(@segmenter.corpus_dfs['it']).to eq(1486)
    end
  end

  context 'with word-size blocks, truncate_all' do
    before(:example) do
      @segmenter = described_class.new(block_size: 3,
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
      expect(@blocks.first.words).to eq(%w(it was the))
    end

    it 'gets the corpus dfs' do
      expect(@segmenter.corpus_dfs['it']).to eq(1486)
    end
  end

  describe '#reset!' do
    it 'resets all the parameters' do
      segmenter = described_class.new
      segmenter.add(@doc.uid)
      segmenter.blocks

      segmenter.reset!
      new_blocks = segmenter.blocks

      expect(new_blocks).to be_empty
    end
  end
end
