class Project  
  def after_create
    self.add_user(self.user)
  end 
end