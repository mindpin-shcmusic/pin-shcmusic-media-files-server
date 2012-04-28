class NilClass
  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

class String
  def blank?
    self.strip.length == 0
  end
end

class TrueClass
  def blank?
    false
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

def file_content_type(file_name)
  MIME::Types.type_for(file_name).first.content_type
rescue
  ext = file_name.split(".")[-1]
  case ext
  when 'rmvb'
    'application/vnd.rn-realmedia'
  else
    'application/octet-stream'
  end
end


# 获取一个随机的文件名
def get_randstr_filename(uploaded_filename)
  ext_name = File.extname(uploaded_filename)

  return "#{randstr}#{ext_name.blank? ? "" : ext_name }".strip
end

# 产生一个随机字符串
def randstr(length=8)
  base = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  size = base.size
  re = '' << base[rand(size-10)]
  (length - 1).times {
    re << base[rand(size)]
  }
  re
end
