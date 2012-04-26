class MergeSliceTempFileResque
  QUEUE_NAME = :merge_slice_temp_file_resque_queue
  @queue = QUEUE_NAME 
  
  def self.enqueue(slice_temp_file_id,media_file_id)
    Resque.enqueue(MergeSliceTempFileResque, slice_temp_file_id,media_file_id)
  end
  
  def self.perform(slice_temp_file_id,media_file_id)
    p ">>>>>>>>>>>>>>>>>>>>>>>> #{slice_temp_file_id}"
    slice_temp_file = SliceTempFile.find(slice_temp_file_id)
    slice_temp_file.merge_blob_files_and_move_to_media_file_path_and_post_status_to_sns
  end
end