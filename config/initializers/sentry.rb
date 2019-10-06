# frozen_string_literal: true

if ENV['SENTRY_DSN'].present?
  Raven.configure do |config|
    # Don't send a number of exceptions on to Sentry
    config.excluded_exceptions += [
      # Produced by the user when they request to kill a job
      'JobKilledError',
      # Produced by DelayedJob when a job runs for too long
      'Delayed::WorkerTimeout',
      # Produced by process managers, not indicative of anything
      # happening in our code
      'SignalException'
    ]
  end
end
