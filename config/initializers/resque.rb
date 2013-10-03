# -*- encoding : utf-8 -*-

# Load the server elements of both Resque and resque-scheduler
require 'resque/server'
require 'resque_scheduler/server'

# FIXME: For external job workers, we'll have to fix this.  But not just yet.
Resque.redis = 'localhost:6379'
Resque.inline = Rails.env.development?

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
