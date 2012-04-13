class VideoUtil
  def self.get_info(file_path)
    info_string = `ffmpeg -i #{file_path} 2<&1|grep Stream`

    # 分析音频信息
    audio_info_string = info_string.match("Stream.*Audio:([^\n]*)")[1]
    
    audio_info_arr = audio_info_string.split(",").map{|str|str.strip}
    audio_info = {}
    audio_info[:encode] = audio_info_arr[0]
    audio_info[:sampling_rate] = audio_info_arr[1]
    audio_info[:bitrate] = audio_info_arr[4].match(/\d+/)[0]

    # 分析视频信息
    video_info_string = info_string.match("Stream.*Video:([^\n]*)")[1]
    video_info_arr = video_info_string.split(",").map{|str|str.strip}
    
    video_info = {}
    video_info[:encode] = video_info_arr[0]
    video_info[:size] = video_info_arr[2].match(/\d*x\d*/)[0]
    video_info[:bitrate] = video_info_arr[3].match(/\d+/)[0]
    fps = video_info_arr.select{|info|!info.match("fps").blank?}[0] || "25 fps"
    video_info[:fps] = fps.match(/\d+/)[0]
    
    video_info_string.match(/\d*.*fps/)
    
    {
      :video=>video_info,
      :audio=>audio_info
    }
  end
  
  def self.encode_to_flv(origin_path,flv_path)
    info = VideoUtil.get_info(origin_path)
    fps = info[:video][:fps]
    size = info[:video][:size]
    video_bitrate = info[:video][:bitrate].to_i*1000
    audio_bitrate = info[:audio][:bitrate]
    
    encode_command = "ffmpeg -i #{origin_path} -ar 44100 -ab #{audio_bitrate}   -b:v #{video_bitrate} -s #{size} -r #{fps} -y #{flv_path}" 
    
    `#{encode_command}`
    `yamdi -i #{flv_path} -o #{flv_path}.tmp`
    `rm #{flv_path}`
    `mv #{flv_path}.tmp #{flv_path}`
    p encode_command
  end
  
  def self.is_video?(file_name)
    ext = File.extname(file_name)
    ext = ext.gsub(".","")
    %w(wmv avi dat asf rm rmvb ram mpg mpeg 3gp mov mp4 m4v dvix dv mkv flv vob qt divx cpk fli flc mod).include?(ext)
  end
end