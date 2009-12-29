# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Person < ActiveRecord::Base
  belongs_to :user
  belongs_to :project  
  belongs_to :source_user, :class_name => 'User'
  
#  validates_uniqueness_of :user, :scope => :project
  validates_presence_of :user, :project   # Make sure they both exist and are set

  serialize :permissions

  ROLES = {:observer => 0, :commenter => 1, :participant => 2, :admin => 3}
  PERMISSIONS = [:view,:edit,:delete,:all]

  def owner?
    project.owner?(user)
  end

  def role_name
    key = nil
    ROLES.each{|k,v| key = k if role == v } 
    key
  end

  def name
    user.name
  end
  
  def login
    user.login
  end
  
  def after_create
    project.log_activity(self, 'create', self)
    if project.user == user
      update_attribute :role, ROLES[:admin]
    end
  end
  
  def after_destroy
    project.log_activity(self, 'delete')
    user.recent_projects.delete(project.id)
    user.save!
  end
  
  def user
    User.find_with_deleted(user_id)
  end
end