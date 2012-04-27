class MergeSliceTempFileResque
  @queue = :merge_slice_temp_file_resque_queue
  
  def self.enqueue(slice_temp_file_id)
    Resque.enqueue(MergeSliceTempFileResque, slice_temp_file_id)
  end
  
  def self.perform(slice_temp_file_id)
    p ">>>>>>>>>>>>>>>>>>>>>>>> #{slice_temp_file_id}"
    SliceTempFile.find(slice_temp_file_id).merge_and_save_and_post_status
  end

end