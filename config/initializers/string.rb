class String
  def strip_tags
    ActionController::Base.helpers.strip_tags(self)
  end
end
