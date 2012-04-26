class SliceTempFile < ActiveRecord::Base
  BASE_PATH = "/web/shcmusic/upload_file/slice_temp_files"
  
  validates :creator_id, :file_name, :file_size, :saved_size, :saved_blob_num, :presence => true
  before_validation(:on => :create) do |slice_temp_file|
    slice_temp_file.saved_size = 0
    slice_temp_file.saved_blob_num = 0
    slice_temp_file.uuid = UUIDTools::UUID.random_create.to_s
  end

  def self.get_or_create(file_name,file_size,creator_id)
    slice_temp_file = self.get(file_name,file_size,creator_id)
    if slice_temp_file.blank?
      slice_temp_file = self.create(:file_name=>file_name,:file_size=>file_size,:creator_id=>creator_id)
    end
    
    slice_temp_file
  end
  
  def self.get(file_name,file_size,creator_id)
    self.where(:file_name=>file_name,:file_size=>file_size,:creator_id=>creator_id).first
  end
  
  # 保存文件片段
  def save_new_blob!(file_blob)
    return if is_complete_upload?
    # 保存文件片段
    _save_new_blob__save_file(file_blob)
    # 记录保存进度
    _save_new_blob__update_database!(file_blob)
    # 如果所有文件片段都已经上传完毕，就合并文件并创建 media_file
    if is_complete_upload?
      # post media_file_meta_info 到 sns
      media_file_id = self._post_media_file_meta_info_to_sns(media_file_meta_info)
      # 发送任务到合并队列
      MergeSliceTempFileResque.enqueue(self.id,media_file_id)
    end
  end

  # 合并文件片段
  # 把合并的文件移动到 media_file 应该存放的位置
  # 发送合并完成的状态到 sns
  def merge_blob_files_and_move_to_media_file_path_and_post_status_to_sns
    # 合并文件片段
    slice_temp_file._merge_blob_files!
    # 把合并的文件移动到 media_file 应该存放的位置
    self.media_file_info.move_merged_slice_temp_file_to_media_file_path    
    # 发送合并完成的状态到 sns
    MediaFileInfo.post_media_file_merge_complete(media_file_id)
  end

  # 当前 slice_temp_file 的 文件片段的存放路径
  def path
    File.join(BASE_PATH,self.uuid)
  end
  
  # 合并后的 slice_temp_file 文件的存放的位置
  def file_path 
    File.join(self.path,self.file_name)
  end

  # 当前 slice_temp_file 对应的 media_file_info
  def media_file_info
    MediaFileInfo.new(self)
  end

  # 当前 slice_temp_file 对应的 media_file meta_info
  def media_file_meta_info
    media_file_info.to_hash
  end

  # 所有文件片段是否全部上传完毕
  def is_complete_upload?
    self.saved_size >= self.file_size
  end

  #### 私有方法
  def _save_new_blob__save_file(file_blob)
    FileUtils.mkdir_p(self.path) if !File.exists?(self.path)

    index = self.saved_blob_num
    new_blob_path = File.join(self.path,"blob.#{index}")

    File.open(new_blob_path,"w") do |f|
      f << file_blob.read
    end
  end

  def _save_new_blob__update_database!(file_blob)
    self.saved_blob_num = self.saved_blob_num+1
    self.saved_size = self.saved_size+file_blob.size
    self.save
  end

  def _post_media_file_meta_info_to_sns(meta_info)
    # 发送 media_file_meta_info 到 sns
    url = File.join(PIN_2012_EDU_SITE,"media_files/create_by_edu")
    res = Net::HTTP.post_form(URI.parse(url),meta_info)
    raise "#{res.code} #{res.body}"  if "200" != res.code
    JSON.parse(res.body)["media_file"]["id"]
  end

  # 合并文件片段
  def _merge_blob_files!
    File.open(self.file_path,"w") do |f|
      0.upto(self.saved_blob_num-1) do |index|
        blob_path = File.join(self.path,"blob.#{index}")
        blob = File.open(blob_path,"r")
        f << blob.read
      end
    end
    self.merged = true
    self.save
  end
end
