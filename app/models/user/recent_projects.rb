class User

  serialize :recent_projects_ids

  def recent_projects
    if @recent_projects.nil?
      proj_ids = self.recent_projects_ids
      @recent_projects = @projects.nil? ? Project.find(:all, :conditions => ["id IN (?)", proj_ids]) : 
                                          @projects.select { |p| proj_ids.include? p.id }
      @recent_projects.sort! { |a,b| proj_ids.index(a.id) <=> proj_ids.index(b.id)}
    else
      @recent_projects
    end
    # @recent_projects ||= Project.find(:all, :conditions => ["id IN (?)", self.recent_projects_ids])
  end
  
  def add_recent_project(project)
    self.recent_projects_ids ||= []
    unless self.recent_projects_ids.include?(project.id)
      self.recent_projects_ids = self.recent_projects_ids.unshift(project.id).slice(0,6)
      @recent_projects = nil
      @projects = nil
      self.save(:validate => false)
    end
  end
  
  def remove_recent_project(project)
    self.recent_projects_ids ||= []
    if self.recent_projects_ids.delete(project.id)
      @recent_projects = nil
      self.save(:validate => false)
    end    
  end
  
end