# -*- encoding : utf-8 -*-
require 'resque/server'

# We don't need to have resque-scheduler installed unless we're in production,
# but try to load it so it hooks into the server tabs
begin
  require 'resque_scheduler'
  require 'resque_scheduler/server'
rescue LoadError
  raise if Rails.env.production?
end

# FIXME: For external job workers, we'll have to fix this.  But not just yet.
Resque.redis = 'localhost:6379'
Resque.inline = Rails.env.development?

# Thanks to Brian Clapper for the idea here.
class Resque::Server
  get '/back to admin interface' do
    redirect '/admin'
  end
end

Resque::Server.tabs << 'Back to Admin Interface'
