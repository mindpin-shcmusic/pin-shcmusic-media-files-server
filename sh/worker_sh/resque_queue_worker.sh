#! /bin/sh

. /etc/rc.status
self_dir=`dirname $0`
. $self_dir/../function.sh


queue_name=$1
queue_worker_name="$queue_name"_worker


processor_pid=/web/2010/pids/"$queue_worker_name".pid
log_path=/web/2010/logs/"$queue_worker_name".log


cd $self_dir/../../sites/pin-user-auth
rails_env=$(get_rails_env)

case "$2" in
  start)
    echo "start"
    assert_process_from_pid_file_not_exist $processor_pid
    VVERBOSE=1 INTERVAL=1 QUEUE=$queue_name RAILS_ENV=$rails_env rake environment resque:work 1>>$log_path 2>>$log_path &
    echo $! > $processor_pid 
    rc_status -v
  ;;
  stop)
    echo "stop"
    kill -9 `cat $processor_pid`
    rc_status -v
  ;;
  restart)
    $0 stop
    sleep 1
    $0 start
  ;;
  pause)
    echo "pause"
    kill -12 `cat $processor_pid`
    rc_status -v
  ;;
  cont)
    echo "cont"
    kill -18 `cat $processor_pid`
    rc_status -v
  ;;
  *)
    echo "tip:(start|stop|restart|pause|cont)"
    exit 5
  ;;
esac

exit 0
