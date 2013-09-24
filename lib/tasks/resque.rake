# -*- encoding : utf-8 -*-
# Add the tasks for Resque, resque_pool, and the scheduler, but don't worry
# if we aren't able to load them in development/test.

begin
  require 'resque/tasks'

  task "resque:setup" => :environment do
    begin
      require 'resque_scheduler'
      require 'resque_scheduler/tasks'

      Resque.schedule = YAML.load_file(Rails.root.join('config', 'schedule.yml'))
    rescue LoadError
      raise if Rails.env.production?
    end
  end
rescue LoadError
  raise if Rails.env.production?
end

begin
  require 'resque/pool/tasks'

  task "resque:pool:setup" do
    ActiveRecord::Base.connection.disconnect!
    Resque::Pool.after_prefork do |job|
      ActiveRecord::Base.establish_connection
    end
  end
rescue LoadError
  raise if Rails.env.production?
end
