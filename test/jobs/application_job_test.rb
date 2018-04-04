require 'test_helper'

class MockJob < ApplicationJob
  def perform(task, options = {})
    standard_options(task, options)
  end
end

class ApplicationJobTest < ActiveJob::TestCase
  test 'should query the right translation keys' do
    flexmock(I18n).should_receive(:t)
      .with('mock_job.testing', {}).and_return('wat')

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
