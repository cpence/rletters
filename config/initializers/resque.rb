# -*- encoding : utf-8 -*-

# Let us reap child processes and hot-restart Resque
Resque.after_fork do |job|
  ActiveRecord::Base.establish_connection
end
