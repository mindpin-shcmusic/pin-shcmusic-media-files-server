module PathConfig
  BASE_PATH = File.expand_path("../../../../",__FILE__)
  PIN_SHCMUSIC_PATH = File.expand_path("../../../",__FILE__)

  UNICORN_SH_PATH = File.join(PIN_SHCMUSIC_PATH,"sh")
  WORKER_SH_PATH = File.join(PIN_SHCMUSIC_PATH,"sh/worker_sh")
  SERVERS_SH_PATH = File.join(PIN_SHCMUSIC_PATH,"sh/service_sh")

  REDIS_SERVICE_SH = File.join(SERVERS_SH_PATH,"redis_service.sh")
  RESQUE_WEB_SH = File.join(SERVERS_SH_PATH,"resque_web_service.sh")

  PROJECTS = Dir.entries(File.join(PIN_SHCMUSIC_PATH,"apps")).delete_if{|app|app == "." || app == ".."}

  QUEUES = [
    "media_file_encode_resque_queue",
    "merge_slice_temp_file_resque_queue"
  ]
end
