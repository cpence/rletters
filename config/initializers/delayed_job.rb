# -*- encoding : utf-8 -*-

# We don't want DJ to try to rework jobs; report errors to the user
# and fail quickly.
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 7.days
