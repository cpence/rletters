require 'test_helper'

class CooccurrenceJobTest < ActiveJob::TestCase
  def perform
    @task = create(:task)
    CooccurrenceJob.new.perform(@task,
                               'scoring' => 't_test',
                               'words' => 'was',
                               'window' => '6')
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, CooccurrenceJob.num_datasets
  end

  types = %w(mutual_information t_test log_likelihood)
  words_list = ['disease', 'tropical, disease']
  nums = [%w(num_pairs 10), %w(all 1)]
  types.product(words_list).product(nums).each do |((type, words), (mode, num))|
    test "should run with type '#{type}', mode '#{mode}', and words '#{words}'" do
      task = create(:task, dataset: create(:full_dataset))

      CooccurrenceJob.perform_now(task,
                                  'scoring' => type,
                                  mode => num,
                                  'window' => '25',
                                  'words' => words)

      assert_equal 'Determine significant associations between distant pairs of words', task.reload.name

      # There should be at least one cooccurrence in there ("word word,X.YYYY...")
      assert_match /\n"?\w+,? \w+"?,\d+(\.\d+)?/, task.files.first.result.file_contents(:original)
    end
  end

  test 'should return significance test names' do
    assert_includes CooccurrenceJob.significance_tests, ['Log-likelihood', :log_likelihood]
  end
end
