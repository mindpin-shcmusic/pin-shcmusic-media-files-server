class SliceTempFile < ActiveRecord::Base
  include Paperclip::Glue

  BASE_PATH             = '/web/shcmusic/upload_file/slice_temp_files'
  MEDIA_FILE_BASE_PATH  = '/web/shcmusic/upload_file/media_files/files/'

  CREATE_MEDIA_FILE_URL = URI.parse File.join(PIN_2012_EDU_SITE, 'media_files/create_by_edu')
  
  validates :creator_id, :entry_file_name, :entry_file_size, :saved_size, :presence => true
  before_validation(:on => :create) do |slice_temp_file|
    slice_temp_file.saved_size = 0
  end

  has_attached_file :entry,
    :styles => lambda { |attachment|
      attachment.instance.is_image? ? {
        :large => '460x340#',
        :small => '220x140#'
      } : {}
    },
    :path => lambda { |attachment| instance = attachment.instance.media_file_path }

  def media_file_path
    File.join(MEDIA_FILE_BASE_PATH, "/#{self.media_file_id}/:style/:basename.:extension")
  end

  def self.media_file_path(media_file_id)
    dir = SliceTempFile.new(:media_file_id=>media_file_id, :entry_file_name=>'*').entry.path[0...-1]
    Dir[dir].first
  end

  CONTENT_TYPES = {
    :video    => [
        'avi', 'rm',  'rmvb', 'mp4', 
        'ogv', 'm4v', 'flv', 'mpeg',
        '3gp'
      ].map{|x| file_content_type(x)}.uniq,
    :audio    => [
        'mp3', 'wma', 'm4a',  'wav', 
        'ogg'
      ].map{|x| file_content_type(x)}.uniq,
    :image    => [
        'jpg', 'jpeg', 'bmp', 'png', 
        'png', 'svg',  'tif', 'gif'
      ].map{|x| file_content_type(x)}.uniq,
    :document => [
        'pdf', 'xls', 'doc', 'ppt'
      ].map{|x| file_content_type(x)}.uniq
  }

  def content_kind
    case self.entry_content_type
    when *CONTENT_TYPES[:video]
      :video
    when *CONTENT_TYPES[:audio]
      :audio
    when *CONTENT_TYPES[:image]
      :image
    when *CONTENT_TYPES[:document]
      :document
    end
  end

  def is_image?
    :image == self.content_kind
  end

  def is_video?
    :video == self.content_kind
  end

  # 如果找到实例就返回
  # 如果找不到就创建一个新的并返回
  def self.find_or_create(file_name,file_size, creator_id)
    self.get(file_name, file_size, creator_id) ||
    self.create(
      :entry_file_name => file_name,
      :entry_file_size => file_size,
      :creator_id      => creator_id
    )
  end
  
  def self.get(file_name,file_size,creator_id)
    self.where(
      :entry_file_name => file_name,
      :entry_file_size => file_size,
      :creator_id      => creator_id
    ).first
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
    File.join(self.blob_dir, "blob.#{self.saved_size}")
  end

  # 所有文件片段是否全部上传完毕
  def is_complete_upload?
    self.saved_size >= self.entry_file_size
  end

  def file_merge_complete_url
    URI.parse File.join(PIN_2012_EDU_SITE, "media_files/#{self.media_file_id}/file_merge_complete")
  end

  # -------------


  # TODO 重构
  # 保存文件片段
  def save_new_blob(file_blob)
    return if is_complete_upload?
    # 保存文件片段
    File.open(self.next_blob_path,"w") { |f| f << file_blob.read }

    # 记录保存进度
    self.saved_size += file_blob.size
    self.save

    # 如果所有文件片段都已经上传完毕，就合并文件并创建 media_file
    if is_complete_upload?
      # 发送 media_file_meta_info 到 sns
      res = Net::HTTP.post_form(CREATE_MEDIA_FILE_URL, media_file_info.to_hash)
      raise "#{res.code} #{res.body}" if '200' != res.code

      self.media_file_id = JSON.parse(res.body)['media_file']['id']
      self.save

      # 发送任务到合并队列
      MergeSliceTempFileResque.enqueue(self.id)
    end
  end

  # 当前 slice_temp_file 对应的 media_file_info
  def media_file_info
    MediaFileInfo.new(self)
  end


  # TODO 重构
  def merge_and_save_and_post_status
    # 合并文件片段
    File.open(self.file_path, 'w') { |f|
      Dir[File.join(self.blob_dir, 'blob.*')].sort { |a, b|
        a.split('.')[-1].to_i <=> b.split('.')[-1].to_i
      }.each { |blob_path|
        File.open(blob_path, 'r') { |blob_f| f << blob_f.read }
      }
    }

    self.entry  = File.open(self.file_path, 'r')
    self.merged = true
    self.save

    # 发送 创建完成状态 给 sns
    res = Net::HTTP.post_form(self.file_merge_complete_url, {})
    raise "#{res.code} #{res.body}" if '200' != res.code

    # 如果是视频就转码
    if is_video?
      MediaFileEncodeResque.enqueue(self.media_file_id)
    end
  end


end
