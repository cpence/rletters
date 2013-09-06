#!/bin/sh
#
# Author: Jamie Winsor (<jamie@vialstudios.com>)
#
# chkconfig: 345 99 1
# Description: Bluepill loader for RLetters
# Provides: rletters
# Default-Start: 3 4 5
# Default-Stop: 0 1 2 6

BLUEPILL_BIN=/usr/local/bin/bluepill
BLUEPILL_CONFIG=/opt/rletters/root/config/bluepill.rb

case "$1" in
  start)
    echo "Loading bluepill configuration for rletters "
    $BLUEPILL_BIN load $BLUEPILL_CONFIG
    ;;
  stop)
    $BLUEPILL_BIN rletters stop
    $BLUEPILL_BIN quit
    ;;
  restart)
    $0 stop
    $0 start
    ;;
  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac
