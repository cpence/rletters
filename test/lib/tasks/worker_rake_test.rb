require 'test_helper'
require 'rake'

class FailingRakeTestJob < ApplicationJob
  queue_as :analysis

  def perform(task, options = {})
    standard_options(task, options)
    fail Exception, 'oh no'
  end
end

class LongRakeTestJob < ApplicationJob
  queue_as :analysis

  def perform(task, options = {})
    standard_options(task, options)
    sleep 1000
    puts 'never reached'
  end
end

class WorkerRakeTest < ActiveSupport::TestCase
  setup do
    # Some glue to make Rake testing work. Thanks to
    # https://robots.thoughtbot.com/test-rake-tasks-like-a-boss
    task_path = File.join('lib', 'tasks', 'worker')
    loaded_files_excluding_current_rake_file = $".reject {|file| file == Rails.root.join("#{task_path}.rake").to_s }

    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require(task_path, [Rails.root.to_s], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment)

    # Only for this test, we actually do want to delay jobs in testing
    Delayed::Worker.delay_jobs = true
    Delayed::Worker.max_run_time = 2.seconds
  end

  teardown do
    Delayed::Worker.delay_jobs = false
    Delayed::Worker.max_run_time = 1.day
  end

  test 'should destroy failing jobs' do
    # Create the task
    task = create(:task)
    FailingRakeTestJob.perform_later(task)

    refute task.failed
    assert_equal 1, Delayed::Job.count

    # Call the Rake runner, which should itself fail
    assert_raises(Exception) do
      @rake['rletters:jobs:analysis_work'].invoke
    end

    # It should have set the task's failed bit and destroyed the job
    assert task.reload.failed
    assert_equal 0, Delayed::Job.count
  end

  test 'should destroy long-running jobs' do
    # Create the task
    task = create(:task)
    LongRakeTestJob.perform_later(task)

    # Call the Rake runner, which should itself fail
    assert_raises(Exception) do
      @rake['rletters:jobs:analysis_work'].invoke
    end

    # It should have set the task's failed bit and destroyed the job
    assert task.reload.failed
    assert_equal 0, Delayed::Job.count
  end
end
