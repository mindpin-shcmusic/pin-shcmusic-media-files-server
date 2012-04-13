class Multimedia
  attr_reader :uuid
  def initialize(name,uuid)
    @uuid = uuid
    @name = name    
  end
  
  def _save_file(file)
    save_path = _save_path
    FileUtils.mkdir_p(File.dirname(save_path))
    
    FileUtils.mv(file.path, save_path)
  rescue SystemCallError
    FileUtils.cp(file.path, save_path)
    FileUtils.rm(file.path)
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
    def create(name,file)
      uuid = UUIDTools::UUID.random_create.to_s
      multi_media = self.new(name,uuid)
      multi_media._save_file(file)
      multi_media.into_the_encode_queue_if_is_video
      multi_media
    end
  end
end