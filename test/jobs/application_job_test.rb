require 'test_helper'

class MockJob < ApplicationJob
  def perform(task, options = {})
    standard_options(task, options)
  end
end

class ApplicationJobTest < ActiveJob::TestCase
  teardown do
    # FIXME: required?
    clean_que_jobs
  end

  class FailJob < ApplicationJob
    include QueJobHelper

    def perform(_)
      mock_que_job

      # This is backwards from what you'd expect -- we want to fail if we
      # have done the right thing (namely, if stats = 1), because raising an
      # exception here makes the test pass
      fail ArgumentError if RLetters::Que::Stats.stats[:total] == 1
    end
  end

  test 'should cleanly handle job failure' do
    task = create(:task)

    FailJob.perform_now(task)

    assert_equal true, task.reload.failed
    assert_equal 0, RLetters::Que::Stats.stats[:total]
  end

  test 'should query the right translation keys' do
    I18n.expects(:t).with('mock_job.testing', {}).returns('wat')

    MockJob.t('.testing')
  end

  test 'should get list of job types' do
    assert_includes ApplicationJob.job_list, ExportCitationsJob
  end

  test 'should default to true for available?' do
    assert MockJob.available?
  end

  test 'should return single dataset' do
    task = create(:task)
    job = MockJob.new
    job.perform(task)

    assert_equal task.dataset, job.dataset
  end

  test 'should fail to return multiple datasets through dataset' do
    task = create(:task)
    job = MockJob.new
    dataset_2 = create(:dataset, user: task.dataset.user)
    job.perform(task, other_datasets: [dataset_2.to_param])

    assert_raises(ArgumentError) { job.dataset }
  end

  test 'should fail to return single dataset through datasets' do
    task = create(:task)
    job = MockJob.new
    job.perform(task)

    assert_raises(ArgumentError) { job.datasets }
  end

  test 'should return multiple datasets' do
    task = create(:task)
    job = MockJob.new
    dataset_2 = create(:dataset, user: task.dataset.user)
    job.perform(task, other_datasets: [dataset_2.to_param])

    assert_equal [task.dataset, dataset_2], job.datasets
  end

  test 'should fail check_task when we kill the job' do
    task = create(:task)
    job = MockJob.new
    job.perform(task)
    task.destroy

    assert_raises(JobKilledError) { job.dataset }
  end
end
