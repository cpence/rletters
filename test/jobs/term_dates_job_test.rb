require 'test_helper'

class TermDatesJobTest < ActiveJob::TestCase
  def perform
    @task = create(:task)
    TermDatesJob.new.perform(@task, 'term' => 'disease')
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, TermDatesJob.num_datasets
  end

  test 'should work' do
    task = create(:task, dataset: create(:dataset))
    create(:query, dataset: task.dataset, q: "uid:\"gutenberg:3172\"")

    TermDatesJob.perform_now(task,
                             'term' => 'disease')

    assert_equal 'Plot word occurrences by date', task.reload.name
    assert_equal 2, task.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')

    data = JSON.load(task.file_for('application/json').result.file_contents(:original))
    assert_kind_of Hash, data

    # Data is reasonable
    assert_includes [1895, 2009], data['data'][0][0]
    assert_includes 0..10, data['data'][0][1]

    # Fills in intervening years between new and old documents with zeros
    refute_nil data['data'].find { |y| y[1] == 0}

    # Data is sorted by year
    assert_equal data['data'].sort_by { |d| d[0] }, data['data']
  end
end
