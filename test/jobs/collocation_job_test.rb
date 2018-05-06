# frozen_string_literal: true
require 'test_helper'

class CollocationJobTest < ActiveJob::TestCase
  setup do
    @old_path = ENV['NLP_TOOL_PATH']
    ENV['NLP_TOOL_PATH'] = 'stubbed'

    @words = build(:parts_of_speech)
    RLetters::Analysis::NLP.stubs(:parts_of_speech).returns(@words)
  end

  teardown do
    ENV['NLP_TOOL_PATH'] = @old_path
  end

  def perform
    @task = create(:task, dataset: create(:full_dataset, num_docs: 2))
    CollocationJob.new.perform(@task, 'scoring' => 'mutual_information')
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, CollocationJob.num_datasets
  end

  types = %w(mutual_information t_test log_likelihood parts_of_speech)
  nums = [%w(num_pairs 10), %w(all 1)]
  types.product(nums).each do |(type, (mode, num))|
    test "should run with type '#{type}', mode '#{mode}'" do
      task = create(:task, dataset: create(:full_dataset, num_docs: 2))

      CollocationJob.perform_now(task,
                                 'scoring' => type,
                                 mode => num)

      assert_equal 'Determine significant associations between immediate pairs of words', task.reload.name

      # There should be at least one collocation in there ("word word,X.YYYY...")
      assert_match /\n"?\w+,? \w+"?,\d+(\.\d+)?/, task.files.first.result.download
    end
  end

  test 'should return significance test names' do
    assert_includes CollocationJob.significance_tests, ['Log-likelihood', :log_likelihood]
  end
end
