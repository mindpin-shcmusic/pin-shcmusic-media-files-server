class SliceTempFile < ActiveRecord::Base
  BASE_PATH = "/web/shcmusic/upload_file/slice_temp_files"
  
  
  validates :creator_id, :file_name, :file_size, :path, :saved_size, :saved_blob_num, :presence => true
  before_validation(:on => :create) do |slice_temp_file|
    slice_temp_file.saved_size = 0
    slice_temp_file.saved_blob_num = 0
    slice_temp_file.path = File.join(BASE_PATH,UUIDTools::UUID.random_create.to_s)
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
  
  def saved(file_blob)
    return if is_complete_upload?
    # 保存文件片段
    FileUtils.mkdir_p(self.path) if !File.exists?(self.path)
    File.open(self._new_blob_path,"w") do |f|
      f << file_blob.read
    end
    
    # 记录保存进度
    self.saved_blob_num = self.saved_blob_num+1
    self.saved_size = self.saved_size+file_blob.size
    _merge_blob if is_complete_upload?
    self.save
  end

  def create_multi_media
    raise "文件还没有上传完毕" if !is_complete_upload?
    # 保存文件
    multi_media = Multimedia.create(self.file_name,self.file_path)
    # 组装文件的 meta 信息
    meta_info = _build_meta_info(multi_media)
    # 发送文件 meta 信息到 sns
    res = Net::HTTP.post_form(URI.parse('http://dev.sns.yinyue.edu/media_files/create_by_edu'),meta_info)
    raise "#{res.code} #{res.body}"  if "200" != res.code
    multi_media.into_the_encode_queue_if_is_video
    res.body
  end
  
  def file_path 
    File.join(self.path,self.file_name)
  end

  def content_type
    MIME::Types.type_for(file_name).first.content_type
  rescue
    "application/octet-stream"
  end

  def is_complete_upload?
    self.saved_size >= self.file_size
  end
  
  def _merge_blob
    File.open(self.file_path,"w") do |f|
      0.upto(self.saved_blob_num-1) do |index|
        blob_path = File.join(self.path,"blob.#{index}")
        blob = File.open(blob_path,"r")
        f << blob.read
      end
    end
  end
  
  def _new_blob_path
    index = self.saved_blob_num
    File.join(self.path,"blob.#{index}")
  end

  def _build_meta_info(multi_media)
    params = {
            :name=>self.file_name,:type=>self.content_type,
            :size=>self.file_size,:uuid=>multi_media.uuid,:creator_id=>creator_id
          }
    if multi_media.is_video?
      params[:video_encode_status] = "ENCODING" 
    end

    params
  end
end
