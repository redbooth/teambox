class User
  
  def observable?(user)
    projects_shared_with(user).any? || user == self
  end
  
  def can_search?
    APP_CONFIG['allow_search']
  end
  
end