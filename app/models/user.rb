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
  
  LANGUAGES = [['English', 'en'], ['Español', 'es'], ['Français', 'fr']]
    
  has_many :projects_owned, :class_name => 'Project', :foreign_key => 'user_id'
  has_many :comments
  has_many :people
  has_many :projects, :through => :people, :order => 'name ASC'
  has_many :invitations, :foreign_key => 'invited_user_id'
  has_many :activities      
  has_many :uploads

  belongs_to :invited_by, :class_name => 'User'

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
    
    if invitation = Invitation.find_by_email(email)
      self.invited_by = invitation.user
      invitation.user.update_attribute :invited_count, (invitation.user.invited_count + 1)
    end
  end

  def after_create
    send_activation_email unless self.confirmed_user

    if invitations = Invitation.find_all_by_email(email)
      for invitation in invitations
        person = invitation.project.people.new(:user => self, :source_user_id => invitation.user)
        person.save
        invitation.destroy
      end
    end
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
    creator_id ||= target.user_id
    Activity.log(nil, target, action, creator_id)
  end

  # Rewriting ActiveRecord's touch method
  # The original runs validations and loads associated models, being very inefficient
  def touch
    self.update_attribute(:updated_at, Time.now)
  end

  def contacts_not_in_project(project)
    conditions = ["project_id IN (?)", Array(self.projects).collect{ |p| p.id } ]

    people = Person.find(:all,
      :select => 'user_id',
      :conditions => conditions,
      :limit => 300)

    user_ids_in_project = project.users.collect { |u| u.id }

    user_ids = people.reject! do |p|
      user_ids_in_project.include?(p.user_id)
    end.collect { |p| p.user_id }.uniq
    
    conditions = ["id IN (?) AND deleted_at IS NULL", user_ids]
    
    User.find(:all,
      :conditions => conditions,
      :order => 'updated_at ASC',
      :limit => 10)
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.user :id => id do
      xml.tag! 'first-name', first_name
      xml.tag! 'last-name', last_name
      # xml.tag! 'email', email
      xml.tag! 'language', language
      xml.tag! 'username', login
      xml.tag! 'time_zone', time_zone
      xml.tag! 'biography', biography
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'avatar-url', "http://#{APP_CONFIG['app_domain']}#{avatar.url(:thumb)}"
    end
  end
end