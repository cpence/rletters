# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Jobs::Analysis::WordFrequency do

  it_should_behave_like 'an analysis job'

  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 2, working: true,
                      user: @user)
    @task = create(:analysis_task, dataset: @dataset)

    # Don't perform the analysis
    mock_analyzer = OpenStruct.new(
      blocks: [{'word' => 2, 'other' => 5}, {'word' => 1, 'other' => 6}],
      block_stats: [
        {name: 'first block', tokens: 7, types: 2},
        {name: 'second block', tokens: 7, types: 2}],
      word_list: ['word', 'other'],
      tf_in_dataset: {'word' => 3, 'other' => 11},
      df_in_dataset: {'word' => 2, 'other' => 3},
      num_dataset_tokens: 14,
      num_dataset_types: 2,
      df_in_corpus: {'word' => 123, 'other' => 456})
    allow(RLetters::Analysis::Frequency::FromTF).to receive(:new) do |d, p, a|
      p.call(100)
      mock_analyzer
    end
    allow(RLetters::Analysis::Frequency::FromPosition).to receive(:new) do |d, p, a|
      p.call(100)
      mock_analyzer
    end
  end

  describe '.download?' do
    it 'is true' do
      expect(Jobs::Analysis::WordFrequency.download?).to be true
    end
  end

  describe '.num_datasets' do
    it 'is 1' do
      expect(Jobs::Analysis::WordFrequency.num_datasets).to eq(1)
    end
  end

  describe '#perform' do
    it 'accepts all the various valid parameters' do
      params_to_test =
        [{ user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           block_size: '100',
           split_across: '1',
           num_words: '0' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           block_size: '100',
           split_across: '0',
           num_words: '0' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           num_blocks: '10',
           split_across: '1',
           num_words: '0' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           num_blocks: '10',
           split_across: '1',
           num_words: '0',
           inclusion_list: 'asdf,sdfhj,wert' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           num_blocks: '10',
           split_across: '1',
           num_words: '0',
           exclusion_list: 'asdf,sdfgh,qwert' },
         { user_id: @user.to_param,
           dataset_id: @dataset.to_param,
           task_id: @task.to_param,
           num_blocks: '1',
           split_across: '1',
           num_words: '0',
           stop_list: 'en' }]

      expect {
        params_to_test.each do |params|
          Jobs::Analysis::WordFrequency.perform('123', params)
        end
      }.to_not raise_error
    end

    context 'when all parameters are valid' do
      before(:example) do
        Jobs::Analysis::WordFrequency.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param,
          block_size: '100',
          split_across: 'true',
          num_words: '0')
        @task.reload
        @output = CSV.parse(@task.result.file_contents(:original))
      end

      it 'names the task correctly' do
        expect(@dataset.analysis_tasks[0].name).to eq('Analyze word frequency in dataset')
      end

      it 'creates good CSV' do
        expect(@output).to be_an(Array)
      end
    end

    context 'when no corpus dfs are returned' do
      before(:example) do
        mock_analyzer = OpenStruct.new(
          blocks: [{'word' => 2, 'other' => 5}, {'word' => 1, 'other' => 6}],
          block_stats: [
            {name: 'first block', tokens: 7, types: 2},
            {name: 'second block', tokens: 7, types: 2}],
          word_list: ['word', 'other'],
          tf_in_dataset: {'word' => 3, 'other' => 11},
          df_in_dataset: {'word' => 2, 'other' => 3},
          num_dataset_tokens: 14,
          num_dataset_types: 2,
          df_in_corpus: nil)
        allow(RLetters::Analysis::Frequency::FromTF).to receive(:new) do |d, p, a|
          p.call(100)
          mock_analyzer
        end
        allow(RLetters::Analysis::Frequency::FromPosition).to receive(:new) do |d, p, a|
          p.call(100)
          mock_analyzer
        end

        Jobs::Analysis::WordFrequency.perform(
          '123',
          user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          task_id: @task.to_param,
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
