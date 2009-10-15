require 'digest/sha1'

# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  before_save do |e| 
    e.profile_score = e.completeness_score
    e.profile_percent = e.percent_complete
    e.profile_grade = e.completeness_grade.to_s
  end

  define_completeness_scoring do
    check :biography, lambda { |per| per.biography.present? },    :biography_presence
    check :biography, lambda { |per| per.biography.length > 30 }, :biograhpy_length_short
    check :biography, lambda { |per| per.biography.length > 128 }, :biograhpy_length_average
    check :biography, lambda { |per| per.biography.length > 250 }, :biograhpy_length_long
  end
  
  def profile_complete?
    completeness_score == 100
  end
  
  after_create { |user| user.build_avatar(:x1 => 1, :y1 => 18, :x2 => 240, :y2 => 257, :crop_width => 239, :crop_height => 239, :width => 400, :height => 500).save() }

  has_many :projects_owned, :class_name => 'Project', :foreign_key => 'user_id'
  
  has_many :people
  has_many :projects, :through => :people
  has_many :invitations, :foreign_key => 'invited_user_id'

  has_many :activities
    
  has_one :avatar
  has_many :uploads
    
  serialize :recent_projects
  
  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validates_associated :projects  #, :people Ensure associated people and projects exist

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

  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
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

  def activities_visible_to_user(user)
    shared_projects = self.projects & user.projects
    shared_projects_ids = shared_projects.collect { |project| project.id }
    
    self.activities.select do |activity|
      shared_projects_ids.include? activity.project_id
    end
  end
end
