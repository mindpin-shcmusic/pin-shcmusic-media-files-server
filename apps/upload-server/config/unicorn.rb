# worker 数量
worker_processes 3
# 日志位置
stderr_path "/web/shcmusic/logs/unicorn-upload-server-error.log"
stdout_path "/web/shcmusic/logs/unicorn-upload-server.log"
# 加载 超时设置 监听
preload_app true
timeout 30
listen '/web/shcmusic/sockets/unicorn-upload-server.sock', :backlog => 2048
# pid 位置
pid_file_name = "/web/shcmusic/pids/unicorn-upload-server.pid"
pid pid_file_name
#working_directory SINATRA_ROOT # available in 0.94.0+

# REE GC
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  old_pid = "#{server.config[:pid]}.oldbin"
  
  puts 'pid:'
  puts '-------------------'
  puts server.pid
  puts old_pid
  puts '---------------------'
  
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
  sleep 1
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  # defined?(ActiveRecord::Base) and
  #   ActiveRecord::Base.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end