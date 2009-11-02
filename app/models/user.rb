require 'digest/sha1'

# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class User < ActiveRecord::Base
  concerned_with :activation, :authentication, :completeness, :recent_projects, :validation
  
  def before_save
    self.update_profile_score
    self.recent_projects ||= []
  end
  
  def after_create
    self.build_avatar(:x1 => 1, :y1 => 18, :x2 => 240, :y2 => 257, :crop_width => 239, :crop_height => 239, :width => 400, :height => 500).save
    self.send_activation_email unless self.confirmed_user
  end
  
  def self.find_by_username_or_email(login)
    return unless login
    if login.include? '@' # usernames are not allowed to contain '@'
      find_by_email(login.downcase)
    else
      find_by_login(login.downcase)
    end
  end
  
  def to_s
    self.name
  end

  has_many :projects_owned, :class_name => 'Project', :foreign_key => 'user_id'
  
  has_many :people
  has_many :projects, :through => :people
  has_many :invitations, :foreign_key => 'invited_user_id'

  has_many :activities

  has_one  :avatar
  has_many :uploads

  attr_accessible :login, 
                  :email, 
                  :name, 
                  :biography, 
                  :password, 
                  :password_confirmation, 
                  :avatar, 
                  :time_zone, 
                  :language, 
                  :comments_ascending, 
                  :conversations_first_comment, 
                  :first_day_of_week

  def activities_visible_to_user(user)
    shared_projects = self.projects & user.projects
    shared_projects_ids = shared_projects.collect { |project| project.id }
    
    self.activities.select do |activity|
      shared_projects_ids.include? activity.project_id
    end
  end
end
