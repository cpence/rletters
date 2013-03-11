#!/bin/sh

# Edit this variable:
export RAILS_ROOT=/path/to/application/current

# Get the value of 'application' from your Capistrano deploy configuration.
# Then copy this file to /etc/init.d/god-(application), make it executable,
# and run:
# sudo update-rc.d god-(application) defaults

# To give the deploying user sudo powers over this init script (so that God
# can be restarted when we deploy a new version), you should run visudo and add
# the following line:
# thedeployinguser ALL=(root) NOPASSWD: /etc/init.d/god-(application)

# On Ubuntu, you may also need to add the line
# Defauls       !secure_path
# to prevent sudo from wiping the path to your custom Ruby installation out
# of the $PATH variable when `sudo /etc/init.d/god...` is called.

# Modified from http://tinyurl.com/6w6wzae; thanks to Tim Riley.

### BEGIN INIT INFO
# Provides:             god
# Required-Start:       $all
# Required-Stop:        $all
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    God
### END INIT INFO

NAME=god
DESC=god

set -e

CONFIG_FILE=$RAILS_ROOT/config/god/config
LOG_FILE=$RAILS_ROOT/log/god.log
PID_FILE=$RAILS_ROOT/tmp/pids/god.pid

. /lib/lsb/init-functions

RETVAL=0

case "$1" in
  start)
    echo -n "Starting $DESC: "
    cd $RAILS_ROOT
    bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE
    RETVAL=$?
    echo "$NAME."
    ;;
  stop)
    echo -n "Stopping $DESC: "
    cd $RAILS_ROOT
    bundle exec god quit
    RETVAL=$?
    echo "$NAME."
    ;;
  restart)
    echo -n "Restarting $DESC: "
    cd $RAILS_ROOT
    [ -e $PID_FILE ] && bundle exec god quit
    bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE
    RETVAL=$?
    echo "$NAME."
    ;;
  status)
    cd $RAILS_ROOT
    bundle exec god status
    RETVAL=$?
    ;;
  *)
    echo "Usage: god {start|stop|restart|status}"
    exit 1
    ;;
esac

exit $RETVAL
