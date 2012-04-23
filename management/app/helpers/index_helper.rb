module IndexHelper
  def file_size(size)
    count = size.to_i
    if count < 1024
      "#{count}B"
    elsif count < 1024*1024
      sprintf("%.2f",count/1024.0) + "K"
    else
      sprintf("%.2f",count/(1024*1024.0)) + "M"
    end
  end
  
  def _2(num)
    num>9 ? num : "0#{num}"
  end
  
  def jtime(time)
    return content_tag(:span, '未知', :class=>'date') if time.blank?
    
    local_time = time.localtime
    content_tag(:span, _friendly_relative_time(local_time), :class=>'date', :'data-date'=>local_time.to_i)
  end
  
  private
  # 根据当前时间与time的间隔距离，返回时间的显示格式
  # 李飞编写
  def _friendly_relative_time(time)
    current_time = Time.now
    seconds = current_time.to_i - time.to_i
    
    
    return '片刻前' if seconds < 0
    return "#{seconds}秒前" if seconds < 60
    
    minutes = seconds/60
    return "#{minutes}分钟前" if seconds < 3600
    
    return time.strftime("%H:%M") if seconds < 86400 && current_time.day == time.day
    
    return time.strftime("#{time.month}月#{time.day}日 %H:%M") if current_time.year == time.year
    
    return time.strftime("%Y年#{time.month}月#{time.day}日 %H:%M")
  end
end
