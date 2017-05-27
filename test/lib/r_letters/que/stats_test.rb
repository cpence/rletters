require 'test_helper'

class QueStatsTest < ActiveSupport::TestCase
  teardown do
    # FIXME: Is this needed, or are the transactional tests doing it?
    clean_que_jobs
  end

  test 'includes all four keys' do
    stats = RLetters::Que::Stats.stats

    refute_nil stats[:total]
    refute_nil stats[:running]
    refute_nil stats[:failing]
    refute_nil stats[:scheduled]
  end

  test 'responds to a job' do
    mock_que_job
    stats = RLetters::Que::Stats.stats

    assert_equal 1, stats[:total]
    assert_equal 0, stats[:running]
    assert_equal 0, stats[:failing]
    assert_equal 1, stats[:scheduled]
  end
end
