class CopyMediaFileResque
  @queue = :copy_media_file_resque_queue

  def self.enqueue(slice_temp_file_id,media_file_id)
    Resque.enqueue(CopyMediaFileResque, slice_temp_file_id,media_file_id)
  end
  
  def self.perform(slice_temp_file_id,media_file_id)
    p ">>>>>>>>>>>>>>>>>>>>>>>> #{slice_temp_file_id}"
    SliceTempFile.find(slice_temp_file_id).copy_media_file_and_post_status(media_file_id)
  end
end