# -*- encoding : utf-8 -*-
# Add the tasks for Resque, resque_pool, and the scheduler.  resque-pool is a
# production-only gem, so don't fail if it can't be found.

require 'resque/tasks'
require 'resque_scheduler'
require 'resque_scheduler/tasks'

task "resque:setup" => :environment do
  Resque.schedule = YAML.load_file(Rails.root.join('config', 'schedule.yml'))
end

begin
  require 'resque/pool/tasks'

  task "resque:pool:setup" do
    ActiveRecord::Base.connection.disconnect!
    Resque::Pool.after_prefork do |job|
      ActiveRecord::Base.establish_connection
      Resque.redis.client.reconnect
     end
  end
rescue LoadError
  raise if Rails.env.production?
end
