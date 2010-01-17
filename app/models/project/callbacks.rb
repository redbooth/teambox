class Project  
  
  after_save :remove_from_recent_projects
  
  def after_create
    add_user(user)
  end 

  private

    def remove_from_recent_projects
      if archived?
        user.each do |user|
          user.remove_recent_project(self)
        end
      end
    end

end