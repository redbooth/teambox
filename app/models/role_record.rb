require_dependency 'grab_name'
require_dependency 'watchable'

class RoleRecord < ActiveRecord::Base
  self.abstract_class = true

  include GrabName
  include Watchable
  acts_as_paranoid
  
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