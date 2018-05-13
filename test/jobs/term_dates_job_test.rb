# frozen_string_literal: true

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
    task = create(:task, dataset: create(:full_dataset))
    # Add another article from a much later year, so that we get some
    # intervening zeros
    create(:query,
           dataset: task.dataset,
           q: 'uid:"doi:10.1371/journal.pntd.0001716"')

    TermDatesJob.perform_now(task,
                             'term' => 'disease')

    assert_equal 'Plot word occurrences by date', task.reload.name
    assert_equal 2, task.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')

    data = JSON.parse(task.json)
    assert_kind_of Hash, data

    # Data is reasonable
    assert_includes 2009..2012, data['data'][0][0]
    assert_includes 0..30, data['data'][0][1]

    # Fills in intervening years between new and old documents with zeros
    refute_nil(data['data'].find { |y| y[1].zero? })

    # Data is sorted by year
    assert_equal data['data'].sort_by { |d| d[0] }, data['data']
  end
end
