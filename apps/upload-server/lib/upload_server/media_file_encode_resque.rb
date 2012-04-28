class MediaFileEncodeResque
  QUEUE_NAME = :media_file_encode_resque_queue
  @queue = QUEUE_NAME 
  
  def self.enqueue(media_file_id)
    Resque.enqueue(MediaFileEncodeResque, media_file_id)
  end
  
  def self.perform(media_file_id)
    file_path = SliceTempFile.media_file_path(media_file_id)

    flv_path = "#{file_path}.flv"
    res = VideoUtil.encode_to_flv(file_path,flv_path)
    params = res ? {:result=>"SUCCESS"} : {:result=>"FAILURE"}
    url = File.join(R::EDU_SNS_SITE,"media_files/#{media_file_id}/encode_complete")
    Net::HTTP.post_form(URI.parse(url),params)
  rescue Exception => ex
    p ex.message
    puts ex.backtrace*"\n"
  end
end