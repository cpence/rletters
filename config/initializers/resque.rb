
# Load the server elements of Resque, resque-scheduler
require 'resque/server'
require 'resque/scheduler/server'

# FIXME: For external job workers, we'll have to fix this.  But not just yet.
Resque.redis = Rails.env.production? ? '127.0.0.1:6379' : MockRedis.new
Resque.inline = !Rails.env.production?

# Send our mails delayed, using Resque, on the maintenance queue.
Resque::Mailer.default_queue_name = 'maintenance'
Resque::Mailer.excluded_environments = []

# Thanks to Brian Clapper for the idea here.
module Resque
  class Server
    get '/back to admin interface' do
      redirect '/admin'
    end
  end
end

Resque::Server.tabs << 'Back to Admin Interface'
