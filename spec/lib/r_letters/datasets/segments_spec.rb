require 'rails_helper'

RSpec.describe RLetters::Datasets::Segments do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, num_docs: 10, working: true, user: @user)
  end

  context 'one block for the dataset, splitting across' do
    before(:example) do
      @analyzer = described_class.new(dataset: @dataset)
      @segments = @analyzer.segments
    end

    it 'creates only one block' do
      expect(@segments.size).to eq(1)
    end

    it 'puts all the words in the block' do
      expect(@segments[0].words.size).to eq(4803)
    end

    it 'names the block' do
      expect(@segments[0].name).to eq('Block #1/1')
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['disease']).to eq(8)
      expect(@analyzer.dfs['malaria']).to eq(1)
    end

    it 'gets the corpus dfs' do
      expect(@analyzer.corpus_dfs['disease']).to eq(1104)
    end
  end

  context 'progress reporting' do
    it 'calls the progress function with under and equal to 100' do
      called_sub_100 = false
      called_100 = false

      described_class.new(dataset: @dataset,
                          progress: lambda do |p|
                            if p < 100
                              called_sub_100 = true
                            else
                              called_100 = true
                            end
                          end).segments

      expect(called_sub_100).to be true
      expect(called_100).to be true
    end
  end

  context 'one block per document, not splitting across' do
    before(:example) do
      @analyzer = described_class.new(dataset: @dataset,
                                      split_across: false)
      @segments = @analyzer.segments
    end

    it 'creates ten blocks' do
      expect(@segments.size).to eq(10)
    end

    it 'names the blocks' do
      expect(@segments[0].name).to start_with("Block #1/1 (within 'doi:10.")
      expect(@segments[1].name).to start_with("Block #1/1 (within 'doi:10.")
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['disease']).to eq(8)
      expect(@analyzer.dfs['malaria']).to eq(1)
    end

    it 'gets the corpus dfs' do
      expect(@analyzer.corpus_dfs['disease']).to eq(1104)
    end
  end

  context 'five total blocks, splitting across' do
    before(:example) do
      @analyzer = described_class.new(dataset: @dataset,
                                      num_blocks: 5)
      @segments = @analyzer.segments
    end

    it 'creates five blocks' do
      expect(@segments.size).to eq(5)
    end

    it 'splits the words evenly' do
      expect(@segments.map(&:words).map(&:size)).to match_array([961, 961, 961, 960, 960])
    end

    it 'names the blocks' do
      expect(@segments[0].name).to eq('Block #1/5')
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['disease']).to eq(8)
      expect(@analyzer.dfs['malaria']).to eq(1)
    end

    it 'gets the corpus dfs' do
      expect(@analyzer.corpus_dfs['disease']).to eq(1104)
    end
  end

  context 'truncate_all, splitting across' do
    before(:example) do
      @analyzer = described_class.new(dataset: @dataset,
                                      block_size: 10,
                                      last_block: :truncate_all)
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
      expect(@analyzer.dfs['disease']).to eq(8)
      expect(@analyzer.dfs['malaria']).to eq(1)
    end

    it 'gets the corpus dfs' do
      expect(@analyzer.corpus_dfs['disease']).to eq(1104)
    end
  end

  context 'truncate_all, not splitting across' do
    before(:example) do
      @analyzer = described_class.new(dataset: @dataset,
                                      split_across: false,
                                      block_size: 10,
                                      last_block: :truncate_all)
      @segments = @analyzer.segments
    end

    it 'creates ten blocks' do
      expect(@segments.size).to eq(10)
    end

    it 'puts ten words in each block' do
      expect(@segments[0].words.size).to eq(10)
      expect(@segments[1].words.size).to eq(10)
    end

    it 'names the blocks' do
      expect(@segments[0].name).to start_with("Block #1 of 10 words (within 'doi:")
      expect(@segments[1].name).to start_with("Block #1 of 10 words (within 'doi:")
    end

    it 'sets dfs correctly' do
      expect(@analyzer.dfs['disease']).to eq(8)
      expect(@analyzer.dfs['malaria']).to eq(1)
    end

    it 'gets the corpus dfs' do
      expect(@analyzer.corpus_dfs['disease']).to eq(1104)
    end
  end
end
