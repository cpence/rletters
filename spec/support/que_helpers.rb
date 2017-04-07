
# Helper methods for creating fake Que jobs
module QueHelpers
  def mock_que_job(id = 1, failed = false)
    error_count = 0
    error_count = 1 if failed

    json = [{ 'job_class' => 'FailingJob', 'job_id' => @job_id,
              'queue_name' => 'maintenance', 'arguments' => [],
              'locale' => 'en' }].to_json
    query = <<-SQL
      INSERT INTO que_jobs
      (priority, run_at, job_id, job_class, args, error_count, queue) VALUES
      (100, now(), #{id}, 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper',
      '#{json}', #{error_count}, 'maintenance')
    SQL
    ActiveRecord::Base.connection.execute(query)
  end

  def clean_que_jobs
    # DatabaseRewinder doesn't see Que's custom SQL queries.
    ActiveRecord::Base.connection.execute('DELETE FROM que_jobs')
  end
end

# Activate enqueued job execution on tag
RSpec.configure do |config|
  config.before :example, perform_enqueued: true do
    @old_perform_enqueued_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_jobs
    @old_perform_enqueued_at_jobs = ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
  end

  config.after :example, perform_enqueued: true do
    ActiveJob::Base.queue_adapter.perform_enqueued_jobs = @old_perform_enqueued_jobs
    ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = @old_perform_enqueued_at_jobs
  end
end
