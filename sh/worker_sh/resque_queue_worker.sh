#! /usr/bin/env bash

self_dir=`dirname $0`
. $self_dir/../function.sh


queue_name=$1
queue_worker_name="$queue_name"_worker


processor_pid=/web/shcmusic/pids/"$queue_worker_name".pid
log_path=/web/shcmusic/logs/"$queue_worker_name".log


cd $self_dir/../../apps/upload-server
rails_env=$(get_rails_env)

case "$2" in
  start)
    echo "start"
    assert_process_from_pid_file_not_exist $processor_pid
    VVERBOSE=1 INTERVAL=1 QUEUE=$queue_name RAILS_ENV=$rails_env rake resque:work 1>>$log_path 2>>$log_path &
    echo $! > $processor_pid
    command_status
  ;;
  stop)
    echo "stop"
    kill -9 `cat $processor_pid`
    command_status
  ;;
  restart)
    $0 stop
    sleep 1
    $0 start
  ;;
  pause)
    echo "pause"
    kill -12 `cat $processor_pid`
    command_status
  ;;
  cont)
    echo "cont"
    kill -18 `cat $processor_pid`
    command_status
  ;;
  *)
    echo "tip:(start|stop|restart|pause|cont)"
    exit 5
  ;;
esac

exit 0
