class User
  
  def observable?(user)
    projects_shared_with(user).any? || user == self
  end
  
end