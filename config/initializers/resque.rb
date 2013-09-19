# -*- encoding : utf-8 -*-
require 'resque/server'

# FIXME: For external job workers, we'll have to fix this.  But not just yet.
Resque.redis = 'localhost:6379'

class Resque::Server
  get '/admin' do
    redirect '/admin'
  end
end

Resque::Server.tabs << 'Admin'
