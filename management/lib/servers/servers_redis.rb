module ServersRedis
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    include PathConfig

    REDIS_CLIENT = Redis.new(:thread_safe=>true)
    def redis_service_state
      pid_file_path = "/web/shcmusic/pids/redis_service.pid"
      ManagementUtil.check_process_by_pid_file(pid_file_path)
    end

    def redis_service_start?
      redis_service_state == "正常运行"
    end

    def start_redis_service
      Dir.chdir(SERVERS_SH_PATH){ `bash #{REDIS_SERVICE_SH} start` }
    end

    def stop_redis_service
      Dir.chdir(SERVERS_SH_PATH){ `bash #{REDIS_SERVICE_SH} stop` }
    end

    def restart_redis_service
      Dir.chdir(SERVERS_SH_PATH){ `bash #{REDIS_SERVICE_SH} restart` }
    end

    # 返回redis的状态
    def check_redis_stats
      REDIS_CLIENT.info
    end

    # 对redis进行重置
    def redis_flush_all
      REDIS_CLIENT.flushall
    end

    # 对redis_cache 进行重置
    def redis_cache_flush
      redis_flushdb(2)
    end

    # 对redis_tip 进行重置
    def redis_tip_flush
      redis_flushdb(1)
    end

    # 对redis_queue 进行重置
    def redis_queue_flush
      redis_flushdb(0)
    end

    # 对 redis 第 count 个数据库进行重置
    def redis_flushdb(count)
      REDIS_CLIENT.select(count)
      REDIS_CLIENT.flushdb
    end

  end
end
