class VideoUtil

  def self.get_info(file_path)
    stream_info_string = `ffmpeg -i '#{file_path}' 2<&1|grep Stream`

    # 分析音频信息
    audio_info_string = stream_info_string.match("Stream.*Audio:([^\n]*)")[1]

    audio_info_arr = audio_info_string.split(",").map{|str|str.strip}
    audio_info = {}
    audio_info[:encode] = audio_info_arr[0]
    audio_info[:sampling_rate] = audio_info_arr[1]
    audio_info[:bitrate] = audio_info_arr[4].match(/\d+/)[0]

    # 分析视频信息
    video_info_string = stream_info_string.match("Stream.*Video:([^\n]*)")[1]
    video_info_arr = video_info_string.split(",").map{|str|str.strip}

    video_info = {}
    video_info[:encode] = video_info_arr[0]
    video_info[:size] = video_info_arr[2].match(/\d*x\d*/)[0]
    video_info[:bitrate] = video_info_arr[3].match(/\d+/)[0]
    fps = video_info_arr.select{|info|!info.match("fps").blank?}[0] || "25 fps"
    video_info[:fps] = fps.match(/\d+/)[0]

    time_info_string = `ffmpeg -i '#{file_path}' 2<&1|grep Duration`

    time = time_info_string.match(/Duration: (\d+:\d+:\d+.\d+),/)[1]

    {
      :video=>video_info,
      :audio=>audio_info,
      :time=>time
    }
  rescue
    nil
  end

  def self.screenshot(origin_path,screenshot_dir,screenshot_count=10)
    info = VideoUtil.get_info(origin_path)
    if info.blank?
      self.record_encode_fail_log(origin_path)
      return false 
    end

    info[:time][/(\d+):(\d+):(\d+).\d+/]
    seconds = $1.to_i*60*60+$2.to_i*60+$3.to_i

    timestamps = []
    step = seconds/(screenshot_count+1)
    0.upto(screenshot_count-1){|index|timestamps << (index+1)*step}
    timestamps.map!{|timestamp|self.second_to_time(timestamp)}

    timestamps.each_with_index do |timestamp,index|
      screenshot_path = File.join(screenshot_dir,"screenshot_#{index+1}.jpg")
      encode_command = "ffmpeg -ss #{timestamp} -i '#{origin_path}' -r 1 -vframes 1 -an -f mjpeg  -y '#{screenshot_path}'" 

      res = `#{encode_command}; echo $?`
      status = res.gsub("\n","").to_i
      if 0 != status
        self.record_encode_fail_log(origin_path)
        return false
      end
    end

  end

  def self.second_to_time(second)
    hour = second/60/60
    minute = second/60-hour*60
    second = second-minute*60-hour*60*60
    "#{sprintf("%.2d",hour)}:#{sprintf("%.2d",minute)}:#{sprintf("%.2d",second)}"
  end
  
  def self.encode_to_flv(origin_path,flv_path)
    info = VideoUtil.get_info(origin_path)
    if info.blank?
      self.record_encode_fail_log(origin_path)
      return false 
    end

    fps = info[:video][:fps]
    size = info[:video][:size]
    video_bitrate = info[:video][:bitrate].to_i*1000
    audio_bitrate = info[:audio][:bitrate]
    
    encode_command = "ffmpeg -i '#{origin_path}' -ar 44100 -ab #{audio_bitrate}   -b:v #{video_bitrate} -s #{size} -r #{fps} -y '#{flv_path}'" 
    
    res = `#{encode_command}; echo $?`
    status = res.gsub("\n","").to_i
    if 0 == status
      `yamdi -i '#{flv_path}' -o '#{flv_path}.tmp'`
      `rm '#{flv_path}'`
      `mv '#{flv_path}.tmp' '#{flv_path}'`
      return true
    else
      self.record_encode_fail_log(origin_path)
      return false
    end
  end

  def self.record_encode_fail_log(origin_path)
    File.open(File.join(PROJECT_ROOT,"log/encode_fail.log"),"a") do |f|
      f << "file #{origin_path} encode fail"
      f << "\n"
    end
  end
  
  def self.is_video?(file_name)
    ext = File.extname(file_name)
    ext = ext.gsub(".","")
    %w(wmv avi dat asf rm rmvb ram mpg mpeg 3gp mov mp4 m4v dvix dv mkv flv vob qt divx cpk fli flc mod).include?(ext)
  end
end