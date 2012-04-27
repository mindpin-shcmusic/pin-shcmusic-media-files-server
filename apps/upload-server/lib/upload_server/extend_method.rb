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
 'application/octet-stream'
end
