require 'digest/sha1'

# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class User < ActiveRecord::Base
  concerned_with :activation, :authentication, :completeness, :recent_projects, :validation
  acts_as_paranoid
  
  LANGUAGES = [['English', 'en'], ['Español', 'es']]
  
  def before_save
    self.update_profile_score
    self.recent_projects ||= []
    self.rss_token = Digest::SHA1.hexdigest(rand(999999999).to_s) if self.rss_token.nil?
  end
  
  def before_create
    self.build_card
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

  has_one :card
  accepts_nested_attributes_for :card
  
  has_many :projects_owned, :class_name => 'Project', :foreign_key => 'user_id'
  has_many :comments
  
  has_many :people
  has_many :projects, :through => :people
  has_many :invitations, :foreign_key => 'invited_user_id'

  has_many :activities

  has_one  :avatar
  has_many :uploads

  attr_accessible :login, 
                  :email, 
                  :first_name, 
                  :last_name,
                  :biography, 
                  :password, 
                  :password_confirmation, 
                  :avatar, 
                  :time_zone, 
                  :language, 
                  :comments_ascending, 
                  :conversations_first_comment, 
                  :first_day_of_week,
                  :card_attributes

  def can_view?(user)
    not projects_shared_with(user).empty?
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
  
  def rss_token
    if read_attribute(:rss_token).nil?
      token = Digest::SHA1.hexdigest(rand(999999999).to_s)
      self.update_attribute(:rss_token, token)
      write_attribute(:rss_token, token)
    end
    
    read_attribute(:rss_token)
  end
  
  def self.find_by_rss_token(t)
    token = t.slice!(0..39)
    user_id = t
    User.find_by_rss_token_and_id(token,user_id)
  end
  
  def read_comments(comment,target)
    if CommentRead.user(self).are_comments_read?(target)
      CommentRead.user(self).read_up_to(comment)
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
    
end