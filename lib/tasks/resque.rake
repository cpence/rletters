# -*- encoding : utf-8 -*-
require 'resque/tasks'
require 'resque/pool/tasks'

task "resque:setup" => :environment do
  # FIXME: For external job workers, we'll have to fix this.  But not just
  # yet.
  Resque.redis = 'localhost:6379'
end

task "resque:pool:setup" do
  ActiveRecord::Base.connection.disconnect!
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
  end
end
