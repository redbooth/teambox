module Enumerable
  def if_defined
    self
  end
end

class NilClass
  def if_defined
    []
  end
end
