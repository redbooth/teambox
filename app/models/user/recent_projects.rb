class User < ActiveRecord::Base

  serialize :recent_projects

  def get_recent_projects
    @recent_projects ||= []
    unless @recent_projects == []
      @recent_projects
    else
      self.recent_projects ||= []
      @recent_projects = self.recent_projects.collect { |p| Project.find(p) }.compact
    end
  end
  
  def add_recent_project(project)
    self.recent_projects ||= []
    
    unless self.recent_projects.include?(project.id)
      self.recent_projects = self.recent_projects.unshift(project.id).slice(0,5)
      @recent_projects = nil
      self.save(false)
    end
  end
  
  def remove_recent_project(project)
    self.recent_projects ||= []
    
    if self.recent_projects.include?(project.id)
      self.recent_projects.delete(project.id)
      @recent_projects = nil
      self.save(false)
    end    
  end

end