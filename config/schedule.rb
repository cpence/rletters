# -*- encoding : utf-8 -*-

set :output, {:standard => 'log/cron.log', :error => 'log/cron_error.log'}

every 1.hours do
  rake "db:sessions:expire"
  rake "db:downloads:expire"
end
