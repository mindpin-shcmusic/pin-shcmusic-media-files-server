#! /usr/bin/env bash

dir=`dirname $0`/../management
pid=/web/shcmusic/pids/unicorn-management.pid
sh_dir=`dirname $0`
. $sh_dir/function.sh

rails_env=$(get_rails_env)
sh_dir_path=$(get_sh_dir_path)
cd $dir


case "$1" in
	start)
		assert_process_from_pid_file_not_exist $pid
		echo "start"
		unicorn_rails -c config/unicorn.rb -D -E $rails_env
		command_status
		;;
	stop)
		echo "stop"
		kill `cat $pid`
		command_status
		;;
	usr2_stop)
		echo "usr2_stop"
		kill -USR2 `cat $pid`
		command_status
		;;
	restart)
		echo "restart"
		$sh_dir_path/`basename $0` stop
		sleep 1
		$sh_dir_path/`basename $0` start
		;;
	*)
		echo "tip:(start|stop|restart|usr2_stop)"
		exit 5
	;;
esac
exit 0
