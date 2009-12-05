class User
  
  def can_view?(user)
    not projects_shared_with(user).empty?
  end
  
end