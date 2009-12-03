# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Person < ActiveRecord::Base
  belongs_to :user
  belongs_to :project  
  belongs_to :source_user, :class_name => 'User'
  
#  validates_uniqueness_of :user, :scope => :project
  validates_presence_of :user, :project   # Make sure they both exist and are set

  serialize :permissions

  ROLES = [:observer,:commenter,:participant,:admin]
  PERMISSIONS = [:view,:edit,:delete,:all]

  def before_destroy
    log_activity(person,'delete')
    user.recent_projects.delete(project.id)
    user.save!    
  end

  def owner?
    project.owner?(user)
  end

  def name
    user.name
  end
  
  def login
    user.login
  end
  
  def after_create
    self.project.log_activity(self, 'create', self)
  end
end