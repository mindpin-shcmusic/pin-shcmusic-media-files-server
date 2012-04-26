class MergeSliceTempFileResque
  QUEUE_NAME = :merge_slice_temp_file_resque_queue
  @queue = QUEUE_NAME 
  
  def self.enqueue(slice_temp_file_id,media_file_id)
    Resque.enqueue(MergeSliceTempFileResque, slice_temp_file_id,media_file_id)
  end
  
  def self.perform(slice_temp_file_id,media_file_id)
    p ">>>>>>>>>>>>>>>>>>>>>>>> #{slice_temp_file_id}"
    slice_temp_file = SliceTempFile.find(slice_temp_file_id)

    # 合并文件片段
    slice_temp_file._merge_blob_files!
    # 把合并的文件移动到 media_file 应该存放的位置
    slice_temp_file.media_file_info.move_merged_slice_temp_file_to_media_file_path    
    # 发送合并完成的状态到 sns
    MediaFileInfo.post_media_file_merge_complete(media_file_id)
  end
end