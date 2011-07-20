class RoleRecord < ActiveRecord::Base

  self.abstract_class = true

  include GrabName
  
  belongs_to :project
  belongs_to :user
  
  def owner?(u)
    user == u
  end
  
  def observable?(user)
    project.observable?(user)
  end

  def editable?(user)
    project.editable?(user)
  end
    
end