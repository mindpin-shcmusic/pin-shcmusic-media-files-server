class MediaFileInfo
  attr_accessor :file_name, :uuid, :slice_temp_file
  def initialize(slice_temp_file)
    @slice_temp_file = slice_temp_file
    @file_name = slice_temp_file.file_name
    @uuid = slice_temp_file.uuid
  end

  def content_type
    MIME::Types.type_for(file_name).first.content_type
  rescue
    "application/octet-stream"
  end

  def file_size
    @slice_temp_file.file_size
  end

  def is_video?
    VideoUtil.is_video?(file_name)
  end

  def file_path
    "/web/shcmusic/upload_file/media_files/files/#{uuid}/original/#{file_name}"
  end

  def move_merged_slice_temp_file_to_media_file_path
    # 创建 media_file 文件存放的目录
    FileUtils.mkdir_p(File.dirname(file_path))
    # 移动合并好的文件到 media_file 应该存放的位置
    merged_slice_temp_file_path = @slice_temp_file.file_path
    FileUtils.mv(merged_slice_temp_file_path, file_path)
  rescue SystemCallError
    FileUtils.cp(merged_slice_temp_file_path, file_path)
    FileUtils.rm(merged_slice_temp_file_path)
  ensure
    FileUtils.chmod(0644,file_path)
  end

  def to_hash
    return {
      :name       => file_name,
      :type       => content_type,
      :size       => file_size,
      :uuid       => uuid,
      :creator_id => slice_temp_file.creator_id,

      :video_encode_status => is_video? ? "ENCODING" : nil
    }
  end


  def self.post_media_file_merge_complete(media_file_id)
    # 发送 创建完成状态 给 sns
    url = File.join(PIN_2012_EDU_SITE,"media_files/#{media_file_id}/file_merge_complete")
    res = Net::HTTP.post_form(URI.parse(url),{})
    raise "#{res.code} #{res.body}"  if "200" != res.code
    res.body
  end

end