class ProjectManagement
  
  class << self
    include PathConfig

    # 操作工程的 启动，关闭，重启，usr
    # param operation 要做的操作
    #       start stop restart usr2_stop
    def operate(project_name,operation)
      check_project_name(project_name)
      unicorn_sh = File.join(UNICORN_SH_PATH,"unicorn.sh")
      raise "不支持 #{operation} 操作" if !["start","stop","restart","usr2_stop"].include?(operation)
      Dir.chdir(UNICORN_SH_PATH) do
        `bash #{unicorn_sh} #{project_name} #{operation}`
      end
    end

    # 可能返回的值: 正常运行 关闭 停止或者僵死
    def state(project_name)
      check_project_name(project_name)
      pid_file_path = find_pid_file_path_by_project_name(project_name)
      ManagementUtil.check_process_by_pid_file(pid_file_path)
    end

    # 查看 工程是否正常运行
    def start?(project_name)
      state(project_name) == "正常运行"
    end

    def log_size(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      File.size(file_path)
    end

    def log_mtime(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      File.mtime(file_path)
    end

    def log_content(project_name)
      file_path = find_log_file_path_by_project_name(project_name)
      return if !File.exist?(file_path)
      ManagementUtil.log_file_content(file_path)
    end

    def pid_count(project_name)
      pid_file_path = find_pid_file_path_by_project_name(project_name)
      ManagementUtil.get_pid_count_by_pid_file(pid_file_path)
    end

    private
    def check_project_name(project_name)
      raise "没有 #{project_name} 这个工程" if !PROJECTS.include?(project_name)
    end
    
    # 根据 工程名 找到 工程进程的 pid文件 的存放路径
    def find_pid_file_path_by_project_name(project_name)
      File.join(BASE_PATH,"pids/unicorn-#{project_name}.pid")
    end

    def find_log_file_path_by_project_name(project_name)
      File.join(PIN_SHCMUSIC_PATH,"apps/#{project_name}/log/#{Rails.env}.log")
    end
  end
end
