class MediaFileEncodeResque
  QUEUE_NAME = :media_file_encode
  @queue = QUEUE_NAME 
  
  def self.enqueue(uuid,file_path)
    Resque.enqueue(MediaFileEncodeResque, uuid, file_path)
  end
  
  def self.perform(uuid,file_path)
    flv_path = "#{file_path}.flv"
    VideoUtil.encode_to_flv(file_path,flv_path)
    params = {:uuid=>uuid,:result=>"SUCCESS"}
    Net::HTTP.post_form(URI.parse('http://dev.sns.yinyue.edu/media_files/encode_complete'),params)
  rescue Exception => ex
    p ex.message
    puts ex.backtrace*"\n"
  end
end