# frozen_string_literal: true

require 'test_helper'

class ProperNamesJobTest < ActiveJob::TestCase
  def perform
    @task = create(:task)
    ProperNamesJob.new.perform(@task)
  end

  include AnalysisJobHelper

  test 'should need one dataset' do
    assert_equal 1, ProperNamesJob.num_datasets
  end

  test 'should be available' do
    assert ProperNamesJob.available?
  end

  test 'should work' do
    task = create(:task, dataset: create(:full_dataset))

    ProperNamesJob.perform_now(task)

    assert_equal 'Extract references to proper names', task.reload.name
    assert_equal 2, task.files.count
    refute_nil task.file_for('application/json')
    refute_nil task.file_for('text/csv')

    data = JSON.parse(task.json)
    assert_kind_of Hash, data

    refute_empty data['names']
    assert_kind_of String, data['names'][0].first
    assert_kind_of Numeric, data['names'][0].second
  end
end
