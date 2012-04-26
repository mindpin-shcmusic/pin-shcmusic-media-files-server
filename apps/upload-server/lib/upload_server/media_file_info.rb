class MediaFileInfo
  attr_accessor :slice_temp_file
  def initialize(slice_temp_file)
    @slice_temp_file = slice_temp_file
  end

  def file_name
    @slice_temp_file.file_name
  end

  def content_type
    MIME::Types.type_for(file_name).first.content_type
  rescue
    "application/unknown"
  end

  # 发送给 sns 用来创建 media_file 记录的 meta_info
  def to_hash
    return {
      :name       => file_name,
      :type       => content_type,
      :size       => @slice_temp_file.file_size,
      :creator_id => slice_temp_file.creator_id,

      :video_encode_status => VideoUtil.is_video?(file_name) ? "ENCODING" : nil
    }
  end
end