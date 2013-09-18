#!/bin/sh
#
# Author: Charles Pence (charles@charlespence.net)
#
# chkconfig: 345 99 1
# Description: Bluepill loader for RLetters
# Provides: rletters
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6

. /etc/rc.d/init.d/functions

# All our Ruby scripts are in /usr/local/bin; put that in the PATH
export PATH=/usr/local/bin:$PATH
BLUEPILL_BIN=/usr/local/bin/bluepill
BLUEPILL_CONFIG=/opt/rletters/root/config/bluepill.rb

PIDFILE=/var/run/bluepill/pids/rletters.pid

RETVAL=0

check() {
  # Make sure we're privileged and the binaries exist
  [ `id -u` = 0 ] || exit 4
  test -x $BLUEPILL_BIN || exit 5
  test -e $BLUEPILL_CONFIG || exit 6
}

start() {
  check
  [ -e $PIDFILE ] && checkpid `cat $PIDFILE` && return 0

  echo -n $"Starting bluepill for rletters: "
  daemon $BLUEPILL_BIN load $BLUEPILL_CONFIG
  RETVAL=$?
  echo

  return $RETVAL
}

stop() {
  check

  echo -n $"Stopping bluepill for rletters: "
  $BLUEPILL_BIN rletters stop
  $BLUEPILL_BIN quit

  RETVAL=$?
  echo
  return $RETVAL
}

restart() {
  stop
  start
}

reload() {
  check

  echo -n $"Reloading bluepill for rletters (in stages): "

  # If we reload all of these services at once, they take so long to start that
  # we'll timeout the bluepill daemon, and all hell will break loose.  Do them
  # one at a time.
  $BLUEPILL_BIN rletters restart resque-0
  $BLUEPILL_BIN rletters restart resque-1
  $BLUEPILL_BIN rletters restart resque-2
  $BLUEPILL_BIN rletters restart clockwork
  $BLUEPILL_BIN rletters restart unicorn

  RETVAL=$?
  echo
  return $RETVAL
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  reload)
    reload
    ;;
  force-reload)
    echo "$0: Unimplemented feature."
    RETVAL=3
    ;;
  restart)
    restart
    ;;
  condrestart)
    [ -e $PIDFILE ] && checkpid `cat $PIDFILE` && restart
    ;;
  status)
    status -p $PIDFILE bluepilld
    RETVAL=$?
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|condrestart|reload|force-reload}"
    RETVAL=2
    ;;
esac

exit $RETVAL
