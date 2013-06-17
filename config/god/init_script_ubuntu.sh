#!/bin/sh

# Edit this variable:
export RAILS_ROOT=/path/to/application/current

# Get the value of 'application' from your Capistrano deploy configuration.
# Then copy this file to /etc/init.d/god-(application), make it executable,
# and run:
# sudo update-rc.d god-(application) defaults

# If your deploy configuration is set to :use_sudo (i.e., root performs
# deploys), you're done.  If a non-root user is deploying, then uncomment
# the next line and set that username here:
# export DEPLOY_USER=thedeployinguser

# Then run visudo and add the following line, to give the deploying user
# permissions to restart God when a new version is deployed:
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
    if [ -z "$DEPLOY_USER" ]; then
      bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE
      RETVAL=$?
    else
      su $DEPLOY_USER -c "bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE"
      RETVAL=$?
    fi
    echo "$NAME."
    ;;
  stop)
    echo -n "Stopping $DESC: "
    cd $RAILS_ROOT
    if [ -z "$DEPLOY_USER" ]; then
      bundle exec god quit
      RETVAL=$?
    else
      su $DEPLOY_USER -c "bundle exec god quit"
      RETVAL=$?
    fi
    echo "$NAME."
    ;;
  restart)
    echo -n "Restarting $DESC: "
    cd $RAILS_ROOT
    if [ -e $PID_FILE ]; then
      if [ -z "$DEPLOY_USER" ]; then
        bundle exec god terminate
      else
        su $DEPLOY_USER -c "bundle exec god terminate"
      fi
    fi
    if [ -z "$DEPLOY_USER" ]; then
      bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE
      RETVAL=$?
    else
      su $DEPLOY_USER -c "bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE"
      RETVAL=$?
    fi
    echo "$NAME."
    ;;
  reload)
    echo -n "Reloading $DESC services: "
    cd $RAILS_ROOT
    if [ -z "$DEPLOY_USER" ]; then
      bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart clockwork
      bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart delayed_job
      bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart unicorn
      RETVAL=$?
    else
      su $DEPLOY_USER -c "bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart clockwork"
      su $DEPLOY_USER -c "bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart delayed_job"
      su $DEPLOY_USER -c "bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart unicorn"
      RETVAL=$?
    fi
    echo "$NAME."
    ;;
  status)
    cd $RAILS_ROOT
    if [ -z "$DEPLOY_USER" ]; then
      bundle exec god status
      RETVAL=$?
    else
      su $DEPLOY_USER -c "bundle exec god status"
      RETVAL=$?
    fi
    ;;
  *)
    echo "Usage: god {start|stop|restart|status}"
    exit 1
    ;;
esac

exit $RETVAL
