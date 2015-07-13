
# Don't run any Que jobs in the active web threads; we will spin up job workers
# to take care of it.
Que.mode = :off
