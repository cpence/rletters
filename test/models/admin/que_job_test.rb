require 'test_helper'

class Admin::QueJobTest < ActiveSupport::TestCase
  teardown do
    # FIXME: Is this needed, or are the transactional tests doing it?
    clean_que_jobs
  end

  test 'should return scheduled jobs' do
    mock_que_job(1)
    mock_que_job(2, true)
    mock_que_job(3, true)
    mock_que_job(4)

    arr = Admin::QueJob.scheduled

    assert_equal [1, 4], arr.map { |j| j.job_id }.sort
  end

  test 'should return failing jobs' do
    mock_que_job(1)
    mock_que_job(2, true)
    mock_que_job(3, true)
    mock_que_job(4)

    arr = Admin::QueJob.failing

    assert_equal [2, 3], arr.map { |j| j.job_id }.sort
  end

  test 'should get single job' do
    mock_que_job(1)
    j = Admin::QueJob.find_by!(job_id: 1)

    refute_nil j.job_id
    refute_nil j.args
  end

  test 'should successfully delete jobs' do
    mock_que_job(1)

    assert_difference('RLetters::Que::Stats.stats[:scheduled]', -1) do
      Admin::QueJob.where(job_id: 1).delete_all
    end
  end

  test 'should reschedule jobs' do
    mock_que_job(1)
    date = 3.days.ago

    Admin::QueJob.where(job_id: 1).update_all(run_at: date)

    assert_in_delta date, Admin::QueJob.find_by!(job_id: 1).run_at, 1.second
  end
end
