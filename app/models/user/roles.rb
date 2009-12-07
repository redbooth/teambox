class User
  
  def observable?(user)
    !projects_shared_with(user).empty? || user == self
  end
  
end