ThinkingSphinx::ActiveRecord.class_eval do
  def primary_key_for_sphinx
    read_attribute(self.class.primary_key_for_sphinx)
  end
end
