require 'digest/sha1'

# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class User < ActiveRecord::Base

  include ActionController::UrlWriter

  acts_as_paranoid
  concerned_with  :activation, 
                  :avatar, 
                  :authentication, 
                  :completeness, 
                  :example_project, 
                  :recent_projects, 
                  :roles, 
                  :rss, 
                  :validation
  
  LANGUAGES = [['English', 'en'], ['Español', 'es']]
    
  has_many :projects_owned, :class_name => 'Project', :foreign_key => 'user_id'
  has_many :comments
  has_many :people
  has_many :projects, :through => :people
  has_many :invitations, :foreign_key => 'invited_user_id'
  has_many :activities      
  has_many :uploads

  has_one :card
  accepts_nested_attributes_for :card

  attr_accessible :login, 
                  :email, 
                  :first_name, 
                  :last_name,
                  :biography, 
                  :password, 
                  :password_confirmation, 
                  :time_zone, 
                  :language, 
                  :conversations_first_comment, 
                  :first_day_of_week,
                  :card_attributes,
                  :avatar,
                  :notify_mentions,
                  :notify_conversations,
                  :notify_task_lists,
                  :notify_tasks
                    
  attr_accessor   :activate

  def before_save
    self.update_profile_score
    self.recent_projects ||= []
    self.rss_token ||= generate_rss_token
  end
  
  def before_create
    self.build_card
    self.first_name = self.first_name.split(" ").collect(&:capitalize).join(" ")
    self.last_name  = self.last_name.split(" ").collect(&:capitalize).join(" ")
  end

  def after_create
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
          
  def projects_shared_with(user)
    self.projects & user.projects
  end

  def activities_visible_to_user(user)
    ids = projects_shared_with(user).collect { |project| project.id }
    
    self.activities.all(:limit => 40, :order => 'created_at DESC').select do |activity|
      ids.include?(activity.project_id) || activity.comment_type == 'User'
    end
  end
    
  def new_comment(user,target,comment)
    self.comments.new(comment) do |comment|
      comment.user_id = user.id
      comment.target = target
    end
  end

  def log_activity(target, action, creator_id=nil)
    creator_id = target.user_id unless creator_id
    Activity.log(nil, target, action, creator_id)
  end

  # Rewriting ActiveRecord's touch method
  # The original runs validations and loads associated models, being very inefficient
  def touch
    self.update_attribute(:updated_at, Time.now)
  end

end