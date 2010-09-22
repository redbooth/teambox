class User
  
  def observable?(user)
    projects_shared_with(user).any? || user == self
  end
  
  def can_search?
    Teambox.config.allow_search
  end
  
end