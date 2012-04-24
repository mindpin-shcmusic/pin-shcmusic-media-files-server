module ServersResqueWeb
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    include PathConfig

    def resque_web_service_state
      pid_file_path = File.join(BASE_PATH,"pids/resque_web_service.pid")
      
      ManagementUtil.check_process_by_pid_file(pid_file_path)
    end

    def resque_web_service_start?
      resque_web_service_state == "正常运行"
    end

    def start_resque_web_service
      p "start_resque_web_service"
      p "bash #{RESQUE_WEB_SH} start"
      Dir.chdir(SERVERS_SH_PATH){ `bash #{RESQUE_WEB_SH} start` }
    end

    def stop_resque_web_service
      Dir.chdir(SERVERS_SH_PATH){ `bash #{RESQUE_WEB_SH} stop` }
    end

    def restart_resque_web_service
      Dir.chdir(SERVERS_SH_PATH){ `bash #{RESQUE_WEB_SH} restart` }
    end
  end
end
