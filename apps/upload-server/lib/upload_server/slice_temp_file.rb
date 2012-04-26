class SliceTempFile < ActiveRecord::Base
  include Paperclip::Glue
  BASE_PATH = "/web/shcmusic/upload_file/slice_temp_files"
  MEDIA_FILE_BASE_PATH = "/web/shcmusic/upload_file/media_files/files/"
  CREATE_MEDIA_FILE_URL = File.join(PIN_2012_EDU_SITE,"media_files/create_by_edu")
  
  validates :creator_id, :entry_file_name, :entry_file_size, :saved_size, :presence => true
  before_validation(:on => :create) do |slice_temp_file|
    slice_temp_file.saved_size = 0
  end

  has_attached_file :entry,
    :styles => {
      :large => '460x340#',
      :small => '220x140#'
    },
    :path => lambda { |attachment| instance = attachment.instance._entry_path}

  def _entry_path
    File.join(MEDIA_FILE_BASE_PATH, "/#{self.media_file_id}/:style/:basename.:extension")
  end


  # 如果找到实例就返回
  # 如果找不到就创建一个新的并返回
  def self.find_or_create(file_name,file_size,creator_id)
    self.get(file_name,file_size,creator_id) ||
    self.create(:entry_file_name=>file_name,:entry_file_size=>file_size,:creator_id=>creator_id)
  end
  
  def self.get(file_name,file_size,creator_id)
    self.where(:entry_file_name=>file_name,:entry_file_size=>file_size,:creator_id=>creator_id).first
  end

  # 当前 slice_temp_file 的 文件片段的存放路径
  def blob_dir
    dir = File.join(BASE_PATH, self.id.to_s)
    FileUtils.mkdir_p(dir)
    dir
  end
  
  # 合并后的 slice_temp_file 文件的存放的位置
  def file_path 
    File.join(self.blob_dir, self.entry_file_name)
  end

  def next_blob_path
    File.join(self.blob_dir,"blob.#{self.saved_size}")
  end

  # 所有文件片段是否全部上传完毕
  def is_complete_upload?
    self.saved_size >= self.entry_file_size
  end

  def media_file_path(media_file_id)
    path = File.join(MEDIA_FILE_BASE_PATH, "/#{media_file_id}/original/#{self.entry_file_name}")
    FileUtils.mkdir_p(File.dirname(path))
    path
  end


  # TODO 重构
  # 保存文件片段
  def save_new_blob(file_blob)
    return if is_complete_upload?
    # 保存文件片段
    File.open(self.next_blob_path,"w") do |f|
      f << file_blob.read
    end
    # 记录保存进度
    self.saved_size = self.saved_size + file_blob.size
    self.save
    # 如果所有文件片段都已经上传完毕，就合并文件并创建 media_file
    if is_complete_upload?
      # 发送 media_file_meta_info 到 sns
      res = Net::HTTP.post_form(URI.parse(CREATE_MEDIA_FILE_URL), media_file_info.to_hash)
      raise "#{res.code} #{res.body}"  if "200" != res.code
      media_file_id = JSON.parse(res.body)["media_file"]["id"]
      # 发送任务到合并队列
      MergeSliceTempFileResque.enqueue(self.id,media_file_id)
    end
  end

  # 当前 slice_temp_file 对应的 media_file_info
  def media_file_info
    MediaFileInfo.new(self)
  end


  # TODO 重构
  def merge_and_save_and_post_status(media_file_id)
    # 合并文件片段
    File.open(self.file_path,"w") do |f|
      Dir[File.join(self.blob_dir,"blob.*")].sort {|a, b|
        a.split(".")[-1].to_i <=> b.split(".")[-1].to_i
      }.each do |blob_path|
        File.open(blob_path,"r") do |blob_f|
          f << blob_f.read
        end
      end
    end

    self.media_file_id = media_file_id
    self.entry = File.open(self.file_path,"r")
    self.merged = true
    self.save
    # 把合并的文件移动到 media_file 应该存放的位置
    #self.save_merged_file(media_file_id)


    # 发送 创建完成状态 给 sns
    url = File.join(PIN_2012_EDU_SITE,"media_files/#{media_file_id}/file_merge_complete")
    res = Net::HTTP.post_form(URI.parse(url),{})
    raise "#{res.code} #{res.body}"  if "200" != res.code

    # 如果是视频就转码 TODO

  end


  def save_merged_file(media_file_id)
    media_file_path = self.media_file_path(media_file_id)
    # 移动合并好的文件到 media_file 应该存放的位置
    FileUtils.mv(self.file_path, media_file_path)
  rescue SystemCallError
    FileUtils.cp(self.file_path, media_file_path)
    FileUtils.rm(self.file_path)
  ensure
    FileUtils.chmod(0644, media_file_path)
  end

end
