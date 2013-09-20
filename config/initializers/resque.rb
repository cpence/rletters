# -*- encoding : utf-8 -*-
require 'resque/server'

# FIXME: For external job workers, we'll have to fix this.  But not just yet.
Resque.redis = 'localhost:6379'

# Thanks to Brian Clapper for the idea here.
class Resque::Server
  get '/back to admin interface' do
    redirect '/admin'
  end
end

Resque::Server.tabs << 'Back to Admin Interface'
