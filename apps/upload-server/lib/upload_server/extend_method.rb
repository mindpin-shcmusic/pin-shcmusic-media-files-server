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
