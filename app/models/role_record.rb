class RoleRecord < ActiveRecord::Base

  self.abstract_class = true

  include GrabName
  
  belongs_to :project
  belongs_to :user

  attr_accessor :dont_push
  attr_accessible :dont_push
  
  def owner?(u)
    user == u
  end
  
  def observable?(user)
    project.observable?(user)
  end

  def editable?(user)
    project.editable?(user)
  end

  def dont_push!
    @dont_push = true
  end
    
end
