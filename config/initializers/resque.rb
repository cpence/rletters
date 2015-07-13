
Resque.redis = Rails.env.production? ? '127.0.0.1:6379' : MockRedis.new
Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
