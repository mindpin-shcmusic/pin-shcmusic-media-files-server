class Multimedia
  attr_reader :uuid
  def initialize(name,uuid)
    @uuid = uuid
    @name = name    
  end
  
  def _save_file(file_path)
    save_path = _save_path
    FileUtils.mkdir_p(File.dirname(save_path))
    
    FileUtils.mv(file_path, save_path)
  rescue SystemCallError
    FileUtils.cp(file_path, save_path)
    FileUtils.rm(file_path)
  ensure
     FileUtils.chmod(0644,save_path)
  end
  
  def _save_path
    "/web/shcmusic/upload_file/media_files/files/#{@uuid}/original/#{@name}"
  end
  
  def is_video?
    VideoUtil.is_video?(@name)
  end
  
  def file_size
    File.size(_save_path)
  end
  
  def into_the_encode_queue_if_is_video
    if is_video?
      MediaFileEncodeResque.enqueue(uuid,_save_path)
    end
  end
  
  class << self
    def create(file_name,file_path)
      uuid = UUIDTools::UUID.random_create.to_s
      multi_media = self.new(file_name,uuid)
      multi_media._save_file(file_path)
      multi_media
    end
  end
end
