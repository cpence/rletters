require 'rails_helper'

RSpec.describe WordFrequencyJob, type: :job do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 2, working: true,
                                     user: @user)
    @task = create(:task, dataset: @dataset)

    # Don't perform the analysis
    mock_analyzer = OpenStruct.new(
      blocks: [{ 'word' => 2, 'other' => 5 }, { 'word' => 1, 'other' => 6 }],
      block_stats: [
        { name: 'first block', tokens: 7, types: 2 },
        { name: 'second block', tokens: 7, types: 2 }],
      word_list: %w(word other),
      tf_in_dataset: { 'word' => 3, 'other' => 11 },
      df_in_dataset: { 'word' => 2, 'other' => 3 },
      num_dataset_tokens: 14,
      num_dataset_types: 2,
      df_in_corpus: { 'word' => 123, 'other' => 456 })
    allow(RLetters::Analysis::Frequency::FromTF).to receive(:new) do |_, p, _|
      p.call(100)
      mock_analyzer
    end
    allow(RLetters::Analysis::Frequency::FromPosition).to receive(:new) do |_, p, _|
      p.call(100)
      mock_analyzer
    end
  end

  describe '.download?' do
    it 'is true' do
      expect(described_class.download?).to be true
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(described_class.num_datasets).to eq(1)
    end
  end

  describe '#perform' do
    it 'accepts all the various valid parameters' do
      params_to_test =
        [{ block_size: '100',
           split_across: '1',
           num_words: '0' },
         { block_size: '100',
           split_across: '1',
           word_method: 'all' },
         { block_size: '100',
           split_across: '0',
           num_words: '0' },
         { num_blocks: '10',
           split_across: '1',
           num_words: '0' },
         { num_blocks: '10',
           split_across: '1',
           num_words: '0',
           inclusion_list: 'asdf,sdfhj,wert' },
         { num_blocks: '10',
           split_across: '1',
           num_words: '0',
           exclusion_list: 'asdf,sdfgh,qwert' },
         { num_blocks: '1',
           split_across: '1',
           num_words: '0',
           stop_list: 'en' },
         { num_blocks: '1',
           split_across: '1',
           ngrams: '2',
           all: '1' }]

      expect {
        params_to_test.each do |params|
          described_class.new.perform(@task, params)
        end
      }.not_to raise_error
    end

    context 'when all parameters are valid' do
      before(:example) do
        described_class.new.perform(
          @task,
          block_size: '100',
          split_across: 'true',
          num_words: '0')
        @task.reload
        @output = CSV.parse(@task.result.file_contents(:original))
      end

      it 'names the task correctly' do
        expect(@dataset.tasks[0].name).to eq('Analyze word frequency in dataset')
      end

      it 'creates good CSV' do
        expect(@output).to be_an(Array)
      end
    end

    context 'when no corpus dfs are returned' do
      before(:example) do
        mock_analyzer = OpenStruct.new(
          blocks: [{ 'word' => 2, 'other' => 5 },
                   { 'word' => 1, 'other' => 6 }],
          block_stats: [
            { name: 'first block', tokens: 7, types: 2 },
            { name: 'second block', tokens: 7, types: 2 }],
          word_list: %w(word other),
          tf_in_dataset: { 'word' => 3, 'other' => 11 },
          df_in_dataset: { 'word' => 2, 'other' => 3 },
          num_dataset_tokens: 14,
          num_dataset_types: 2,
          df_in_corpus: nil)
        allow(RLetters::Analysis::Frequency::FromTF).to receive(:new) do |_, p, _|
          p.call(100)
          mock_analyzer
        end
        allow(RLetters::Analysis::Frequency::FromPosition).to receive(:new) do |_, p, _|
          p.call(100)
          mock_analyzer
        end

        described_class.new.perform(
          @task,
          block_size: '100',
          split_across: 'true',
          num_words: '0')
        @task.reload
        @output = CSV.parse(@task.result.file_contents(:original))
      end

      it 'still works' do
        expect(@output).to be_an(Array)
      end
    end
  end
end
