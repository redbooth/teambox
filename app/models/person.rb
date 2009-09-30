# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class Person < ActiveRecord::Base
  belongs_to :user
  belongs_to :project  
  
  validates_presence_of :user, :project   # Make sure they both exist and are set
  
  def name
    user.name
  end
  
end