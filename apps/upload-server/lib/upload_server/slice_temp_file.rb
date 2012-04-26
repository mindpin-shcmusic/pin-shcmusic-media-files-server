class SliceTempFile < ActiveRecord::Base
  BASE_PATH = "/web/shcmusic/upload_file/slice_temp_files"
  
  validates :creator_id, :file_name, :file_size, :saved_size, :presence => true
  before_validation(:on => :create) do |slice_temp_file|
    slice_temp_file.saved_size = 0
    slice_temp_file.uuid = UUIDTools::UUID.random_create.to_s
  end

  # 如果找到实例就返回
  # 如果找不到就创建一个新的并返回
  def self.find_or_create(file_name,file_size,creator_id)
    self.get(file_name,file_size,creator_id) ||
    self.create(:file_name=>file_name,:file_size=>file_size,:creator_id=>creator_id)
  end
  
  def self.get(file_name,file_size,creator_id)
    self.where(:file_name=>file_name,:file_size=>file_size,:creator_id=>creator_id).first
  end

  # 当前 slice_temp_file 的 文件片段的存放路径
  def blob_dir
    dir = File.join(BASE_PATH, self.uuid)
    FileUtils.mkdir_p(dir)
    dir
  end
  
  # 合并后的 slice_temp_file 文件的存放的位置
  def file_path 
    File.join(self.blob_dir, self.file_name)
  end

  def next_blob_path
    File.join(self.blob_dir,"blob.#{self.saved_size}")
  end

  # 所有文件片段是否全部上传完毕
  def is_complete_upload?
    self.saved_size >= self.file_size
  end







  
  # 保存文件片段
  def save_new_blob(file_blob)
    return if is_complete_upload?
    # 保存文件片段
    _save_new_blob__save_file(file_blob)
    # 记录保存进度
    _save_new_blob__update_database(file_blob)
    # 如果所有文件片段都已经上传完毕，就合并文件并创建 media_file
    if is_complete_upload?
      # post media_file_meta_info 到 sns
      media_file_id = self._post_media_file_meta_info_to_sns(media_file_meta_info)
      # 发送任务到合并队列
      MergeSliceTempFileResque.enqueue(self.id,media_file_id)
    end
  end

  def _save_new_blob__save_file(file_blob)
    File.open(self.next_blob_path,"w") do |f|
      f << file_blob.read
    end
  end

  def _save_new_blob__update_database(file_blob)
    self.saved_size = self.saved_size + file_blob.size
    self.save
  end

  def _post_media_file_meta_info_to_sns(meta_info)
    # 发送 media_file_meta_info 到 sns
    url = File.join(PIN_2012_EDU_SITE,"media_files/create_by_edu")
    res = Net::HTTP.post_form(URI.parse(url),meta_info)
    raise "#{res.code} #{res.body}"  if "200" != res.code
    JSON.parse(res.body)["media_file"]["id"]
  end




###################################






  # 合并文件片段
  def _merge_blob_files!
    File.open(self.file_path,"w") do |f|
      Dir[File.join(self.blob_dir,"blob.*")].sort {|a, b|
        a.split(".")[-1].to_i <=> b.split(".")[-1].to_i
      }.each do |blob_path|
        File.open(blob_path,"r") do |blob_f|
          f << blob_f.read
        end
      end
    end

    self.merged = true
    self.save
  end


  # 当前 slice_temp_file 对应的 media_file_info
  def media_file_info
    MediaFileInfo.new(self)
  end

  # 当前 slice_temp_file 对应的 media_file meta_info
  def media_file_meta_info
    media_file_info.to_hash
  end


end
