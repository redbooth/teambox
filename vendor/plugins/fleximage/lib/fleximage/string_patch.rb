unless "string".respond_to?(:present?)
  class String
    alias_method :present?, :present?
  end
end