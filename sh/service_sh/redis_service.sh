#! /usr/bin/env bash

root_dir=`dirname $0`

processor_pid=/web/shcmusic/pids/redis_service.pid

log_file=/web/shcmusic/logs/redis_service.log

. $root_dir/../function.sh

case "$1" in
        start)
                assert_process_from_pid_file_not_exist $processor_pid
                echo "redis_service start"
                cd $root_dir/../../../redis-2.2.8
                ./src/redis-server 1>> $log_file 2>> $log_file &
                command_status
                echo $! > $processor_pid
        ;;
        stop)
                echo "redis_service stop"
                kill -9 `cat $processor_pid`
                command_status
        ;;
        restart)
                $0 stop
                sleep 1
                $0 start
        ;;
        *)
                echo "tip:(start|stop|restart)"
                exit 5
        ;;
esac
exit 0


