class Project  
  
  def after_destroy
    remove_from_recent_projects
  end
  
  def after_save
    remove_from_recent_projects if archived?
  end
  
  def after_create
    add_user(user)
    log_activity(self, 'create', user_id)
  end

  private

    def remove_from_recent_projects
      users.each do |u|
        u.remove_recent_project(self)
      end
    end

end
