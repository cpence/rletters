
module QueJobHelper
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
    # Database cleaning doesn't see these custom queries (OR DOES IT FIXME)
    ActiveRecord::Base.connection.execute('DELETE FROM que_jobs')
  end
end
