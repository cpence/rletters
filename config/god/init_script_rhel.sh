#!/bin/bash
#
# Modified from https://github.com/leehuffman/rhel-init-scripts/, thanks to
# Lee Huffman.
#
# chkconfig: - 85 15
# description: Control the God gem.
#

# Edit this variable:
export RAILS_ROOT=/path/to/application/current

# Get the value of 'application' from your Capistrano deploy configuration.
# Then copy this file to /etc/init.d/god-(application), make it executable,
# and run:
# sudo chkconfig --add god-(application)
# sudo chkconfig --level 345 god-(application) on

# If your deploy configuration is set to :use_sudo (i.e., root performs
# deploys), you're done.  If a non-root user is deploying, then uncomment
# the next line and set that username here:
# export DEPLOY_USER=thedeployinguser

# Then run visudo and add the following line, to give the deploying user
# permissions to restart God when a new version is deployed:
# thedeployinguser ALL=(root) NOPASSWD: /etc/init.d/god-(application)

### BEGIN INIT INFO
# Provides:          god
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Default-Start:
# Default-Stop:
# Description:       God
# Short-Description: Control God
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

prog=god

# Default values.
CONFIG_FILE=$RAILS_ROOT/config/god/config
LOG_FILE=$RAILS_ROOT/log/god.log
PID_FILE=$RAILS_ROOT/tmp/pids/god.pid

start_god() {
  echo -n $"Starting $prog: "
  status_god_quiet && echo -n "already running" && warning && echo && exit 0
  cd $RAILS_ROOT
  if [ -z "$DEPLOY_USER" ]; then
    bundle exec god -c $CONFIG_FILE -l $LOG_FILE -P $PID_FILE >/dev/null
  else
    sudo -u $DEPLOY_USER RAILS_ROOT="$RAILS_ROOT" bundle exec god -c $CONFIG_FILE -l $LOG_FILE -P $PID_FILE >/dev/null
  fi
  retval=$?
  echo
  return $retval
}

stop_god() {
  echo -n $"Stopping $prog: "
  retval=0
  if ! status_god_quiet ; then
    echo -n "already stopped" && warning
  else
    cd $RAILS_ROOT
    if [ -z "$DEPLOY_USER" ]; then
      bundle exec god terminate >/dev/null
    else
      sudo -u $DEPLOY_USER RAILS_ROOT="$RAILS_ROOT" bundle exec god terminate >/dev/null
    fi
    retval=$?
  fi
  echo
  return $retval
}

restart_god() {
  stop_god
  start_god
}

reload_god() {
  echo -n $"Reloading $prog services: "
  retval=0
  if ! status_god_quiet ; then
    echo -n "not running" && warning && echo && exit 1
  fi

  cd $RAILS_ROOT
  if [ -z "$DEPLOY_USER" ]; then
    bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart clockwork
    bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart delayed_job
    bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart unicorn
    retval=$?
  else
    sudo -u $DEPLOY_USER RAILS_ROOT="$RAILS_ROOT" bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart clockwork
    sudo -u $DEPLOY_USER RAILS_ROOT="$RAILS_ROOT" bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart delayed_job
    sudo -u $DEPLOY_USER RAILS_ROOT="$RAILS_ROOT" bundle exec god -c $CONFIG_FILE -P $PID_FILE -l $LOG_FILE restart unicorn
    retval=$?
  fi

  echo
  return retval
}

status_god() {
  status -p $PID_FILE $prog
}

status_god_quiet() {
  status_god >/dev/null 2>&1
}

case "$1" in
  start)
    start_god
    ;;
  stop)
    stop_god
    ;;
  restart)
    restart_god
    ;;
  reload)
    reload_god
    ;;
  status)
    status_god
    ;;
  *)
    echo $"Usage: $0 {start|stop|status|reload|restart}"
    exit 2
esac

exit $?
