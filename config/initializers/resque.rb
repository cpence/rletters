# -*- encoding : utf-8 -*-

# Load the server elements of Resque, resque-scheduler, resque-status
require 'resque/server'
require 'resque/status_server'
require 'resque_scheduler/server'

# FIXME: For external job workers, we'll have to fix this.  But not just yet.
Resque.redis = Rails.env.production? ? 'localhost:6379' : MockRedis.new
Resque.inline = Rails.env.development?

# We have some long-running jobs, preserve status information for 7 days
Resque::Plugins::Status::Hash.expire_in = 60 * 60 * 24 * 7

# Send our mails delayed, using Resque, on the maintenance queue.  Dont't
# exclude it from any environments, as resque_spec is going to intercept its
# calls in testing anyway.
Resque::Mailer.default_queue_name = 'maintenance'
Resque::Mailer.excluded_environments = []

# Thanks to Brian Clapper for the idea here.
class Resque::Server
  get '/back to admin interface' do
    redirect '/admin'
  end
end

Resque::Server.tabs << 'Back to Admin Interface'
