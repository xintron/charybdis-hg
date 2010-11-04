#!/bin/bash
 
NAME=ircd
DAEMON=/usr/local/ircd/bin/ircd
PIDFILE=/var/run/$NAME.pid
 
. /etc/rc.conf
. /etc/rc.d/functions
 
touch $PIDFILE

case "$1" in
    start)
        stat_busy "Starting ircd"
        [ -z `cat $PIDFILE` ] && `su ircd -c "$DAEMON"`
        PID=`pidof -o %PPID $DAEMON`
        if [ -z $PID ]; then
            stat_fail
        else
            echo $PID > $PIDFILE
            add_daemon $NAME
            stat_done
        fi
        ;;
    stop)
        stat_busy "Stopping ircd"
        if [ ! -z `cat $PIDFILE` ]; then
            PID=`cat $PIDFILE`
            kill $PID > /dev/null
            if [ $? -gt 0 ]; then
                stat_fail
            else
                rm $PIDFILE
                rm_daemon $NAME
                stat_done
            fi
        else
            stat_fail
        fi
        ;;
    restart|force-reload)
        $0 stop
        $0 start
        ;;
    config-test)
        `su ircd -c "$DAEMON -conftest"`
        ;;
    *)
		echo "usage: $0 {start|stop|restart|config-test}"
esac
exit 0
