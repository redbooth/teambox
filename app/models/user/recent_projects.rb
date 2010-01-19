class User

  serialize :recent_projects_ids

  def recent_projects
    @recent_projects ||= Project.find(:all, :conditions => ["id IN (?)", self.recent_projects_ids])
  end
  
  def add_recent_project(project)
    self.recent_projects_ids ||= []
    unless self.recent_projects_ids.include?(project.id)
      self.recent_projects_ids = self.recent_projects_ids.unshift(project.id).slice(0,5)
      @recent_projects = nil
      self.save(false)
    end
  end
  
  def remove_recent_project(project)
    self.recent_projects_ids ||= []
    if self.recent_projects_ids.delete(project.id)
      @recent_projects = nil
      self.save(false)
    end    
  end
  
end