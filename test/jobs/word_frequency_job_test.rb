# frozen_string_literal: true

require 'test_helper'

class WordFrequencyJobTest < ActiveJob::TestCase
  def perform
    @task = create(:task, dataset: create(:full_dataset, num_docs: 2))
    WordFrequencyJob.new.perform(@task)
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, WordFrequencyJob.num_datasets
  end

  test 'should accept all combinations of parameters' do
    params_to_test =
      [{ 'block_size' => '100',
         'split_across' => '1',
         'num_words' => '0' },
       { 'block_size' => '100',
         'split_across' => '1',
         'word_method' => 'all' },
       { 'block_size' => '100',
         'split_across' => '0',
         'num_words' => '0' },
       { 'num_blocks' => '10',
         'split_across' => '1',
         'num_words' => '0' },
       { 'num_blocks' => '10',
         'split_across' => '1',
         'num_words' => '0',
         'inclusion_list' => 'asdf,sdfhj,wert' },
       { 'num_blocks' => '10',
         'split_across' => '1',
         'num_words' => '0',
         'exclusion_list' => 'asdf,sdfgh,qwert' },
       { 'num_blocks' => '1',
         'split_across' => '1',
         'num_words' => '0',
         'stop_list' => 'en' },
       { 'num_blocks' => '1',
         'split_across' => '1',
         'ngrams' => '2',
         'all' => '1' },
       { 'num_blocks' => '1',
         'split_across' => '1',
         'num_words' => '10',
         'word_cloud' => '1',
         'word_cloud_font' => 'Roboto',
         'word_cloud_color' => 'Blues' },
       { 'num_blocks' => '1',
         'split_across' => '1',
         'num_words' => '10',
         'word_cloud' => '1',
         'word_cloud_inclusion_list' => '0' }]

    task = create(:task, dataset: create(:full_dataset, num_docs: 2))

    params_to_test.each do |params|
      WordFrequencyJob.new.perform(task, params)
    end
  end

  test 'should work' do
    task = create(:task, dataset: create(:full_dataset, num_docs: 2))

    WordFrequencyJob.perform_now(task,
                                 'block_size' => '100',
                                 'split_across' => '1',
                                 'num_words' => '0')

    assert_equal 'Analyze word frequency in dataset', task.reload.name

    data = CSV.parse(task.file_for('text/csv').result.download)
    assert_kind_of Array, data
  end

  test 'should still work when no corpus dfs are returned' do
    analyzer = stub(
      blocks: [{ 'word' => 2, 'other' => 5 },
               { 'word' => 1, 'other' => 6 }],
      block_stats: [
        { name: 'first block', tokens: 7, types: 2 },
        { name: 'second block', tokens: 7, types: 2 }
      ],
      word_list: %w[word other],
      tf_in_dataset: { 'word' => 3, 'other' => 11 },
      df_in_dataset: { 'word' => 2, 'other' => 3 },
      num_dataset_tokens: 14,
      num_dataset_types: 2,
      df_in_corpus: nil
    )
    RLetters::Analysis::Frequency.expects(:call)
                                 .returns(analyzer)

    task = create(:task, dataset: create(:full_dataset, num_docs: 2))

    WordFrequencyJob.perform_now(task,
                                 'block_size' => '100',
                                 'split_across' => '1',
                                 'num_words' => '0')

    data = CSV.parse(task.file_for('text/csv').result.download)
    assert_kind_of Array, data
  end
end
