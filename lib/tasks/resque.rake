# Add the tasks for Resque and resque_pool.  resque-pool is a
# production-only gem, so don't fail if it can't be found.

require 'resque/tasks'

begin
  require 'resque/pool'
  require 'resque/pool/tasks'

  task 'resque:pool:setup' do
    ActiveRecord::Base.connection.disconnect!
    Resque::Pool.after_prefork do
      ActiveRecord::Base.establish_connection
      Resque.redis.client.reconnect
    end
  end
rescue LoadError
  raise if Rails.env.production?
end
