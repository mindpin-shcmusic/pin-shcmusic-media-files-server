class ServerManagement

  # 包含的server
  Servers = ['redis_service','resque_web_service']
  
  include ServersRedis
  include ServersResqueWeb
  

  class << self
    include PathConfig
    # 检测服务是否开启
    def start?(server_name)
      check_server_name_param(server_name)
      eval("#{server_name}_start?")
    rescue Exception=>ex
      raise ex
    end

    # 服务的状态
    def state(server_name)
      check_server_name_param(server_name)
      eval("#{server_name}_state")
    end

    # 服务的操作
    def operate(server_name,operation)
      check_server_name_param(server_name)
      eval("#{operation}_#{server_name}")
    rescue Exception=>ex
      raise ex
    end

    def log_size(server_name)
      file_path = find_log_file_path_by_server_name(server_name)
      `touch #{file_path}` if !File.exist?(file_path)
      File.size(file_path)
    end

    def log_mtime(server_name)
      file_path = find_log_file_path_by_server_name(server_name)
      `touch #{file_path}` if !File.exist?(file_path)
      File.mtime(file_path)
    end

    def log_content(server_name)
      file_path = find_log_file_path_by_server_name(server_name)
      `touch #{file_path}` if !File.exist?(file_path)
      ManagementUtil.log_file_content(file_path)
    end

    def pid_count(server_name)
      file_path = find_pid_file_path_by_server_name(server_name)
      ManagementUtil.get_pid_count_by_pid_file(file_path)
    end

    private
    def check_server_name_param(server_name)
      raise "没有 #{server_name} 这个 server_name" if !Servers.include?(server_name)
    end

    def find_log_file_path_by_server_name(server_name)
      if !['redis_service','resque_web_service'].include?(server_name)
        raise "#{server_name} 这个 server_name 没有日志"
      end
      "/web/shcmusic/logs/#{server_name}.log"
    end

    def find_pid_file_path_by_server_name(server_name)
      return "/web/shcmusic/pids/#{server_name}.pid"
    end
  end
end
