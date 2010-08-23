require 'digest/sha1'

# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class User < ActiveRecord::Base

  include ActionController::UrlWriter

  acts_as_paranoid
  concerned_with  :activation,
                  :avatar,
                  :authentication,
                  :example_project,
                  :recent_projects,
                  :roles,
                  :rss,
                  :scopes,
                  :validation,
                  :task_reminders

  LOCALE_CODES = I18n.available_locales.map(&:to_s)

  has_many :projects_owned, :class_name => 'Project', :foreign_key => 'user_id'
  has_many :comments
  has_many :people
  has_many :projects, :through => :people, :order => 'name ASC'
  has_many :invitations, :foreign_key => 'invited_user_id'
  has_many :activities
  has_many :uploads
  has_many :app_links
  has_many :memberships

  has_many :organizations, :through => :memberships
  has_many :admin_organizations, :through => :memberships, :source => :organization, :conditions => {'memberships.role' => Membership::ROLES[:admin]}

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
                  :locale,
                  :first_day_of_week,
                  :betatester,
                  :card_attributes,
                  :notify_mentions,
                  :notify_conversations,
                  :notify_task_lists,
                  :notify_tasks,
                  :wants_task_reminder

  attr_accessor   :activate

  before_validation :sanitize_name
  before_destroy :rename_as_deleted

  def before_save
    self.recent_projects_ids ||= []
    self.rss_token ||= generate_rss_token
    self.visited_at = Time.now
  end

  def before_create
    if invitation = Invitation.find_by_email(email)
      self.invited_by = invitation.user
      invitation.user.update_attribute :invited_count, (invitation.user.invited_count + 1)
    end
  end

  def after_create
    send_activation_email unless self.confirmed_user

    if invitations = Invitation.find_all_by_email(email)
      for invitation in invitations
        invitation.accept(self)
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
    name
  end

  def to_param
    login_was # in case it changes but is not yet saved
  end

  def visited_at
    read_attribute(:visited_at) || updated_at
  end
  
  def locale
    if LOCALE_CODES.include? self[:locale]
      self[:locale]
    else
      I18n.default_locale.to_s
    end
  end

  def projects_shared_with(user)
    self.projects & user.projects
  end

  def shares_invited_projects_with?(user)
    Invitation.count(:conditions => {:project_id => user.project_ids, :invited_user_id => self.id}) > 0
  end
  
  def users_with_shared_projects
    ids = self.projects.map(&:user_ids).flatten
    ids += Invitation.find(:all, :conditions => {:project_id => self.project_ids}, :select => 'user_id').map(&:user_id)
    
    User.find(:all, :conditions => {:id => ids.uniq})
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

  def update_visited_at
    if visited_at.nil? or (Time.now - visited_at) >= 12.hours
      update_attribute(:visited_at, Time.now)
    end
  end
  
  def person_for(project)
    self.people.find_by_project_id(project.id)
  end
  
  def member_for(organization)
    self.memberships.find_by_organization_id(organization.id)
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
      :order => 'updated_at DESC',
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
      xml.tag! 'locale', locale
      xml.tag! 'username', login
      xml.tag! 'time_zone', time_zone
      xml.tag! 'biography', biography
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'avatar-url', avatar_or_gravatar_url(:thumb)
    end
  end
  
  def to_api_hash(options = {})
    {
      :id => id,
      :first_name => first_name,
      :last_name => last_name,
      :locale => locale,
      :username => login,
      :time_zone => time_zone,
      :biography => biography,
      :created_at => created_at.to_s(:db),
      :updated_at => updated_at.to_s(:db),
      :avatar_url => avatar_or_gravatar_url(:thumb)
    }
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end

  def in_project(project)
    project.people.select { |person| person.user_id == self.id }.first
  end

  def contacts
    conditions = ["project_id IN (?)", Array(self.projects).collect{ |p| p.id } ]
    user_ids = Person.find(:all,
      :select => 'user_id',
      :conditions => conditions,
      :limit => 300).collect { |p| p.user_id }.uniq
    conditions = ["id IN (?) AND deleted_at IS NULL AND id != (?)", user_ids, self.id]
    User.find(:all,
      :conditions => conditions,
      :order => 'updated_at DESC',
      :limit => 60)
  end

  def active_projects_count
    projects.unarchived.count
  end

  def can_create_project?
    true
  end

  def notify_of_project_comment?(comment)
    self.notify_mentions &&
      comment.user != self &&
      !!( comment.body =~ /@all/i || comment.body =~ /@#{self.login}[^a-z0-9_]/i )
  end

  DELETED_TAG = "deleted"
  DELETED_REGEX = /#{DELETED_TAG}\d+__(.*)/i

  def rename_as_deleted
    tag = find_available_deleted_tag
    update_attribute :login, "#{tag}#{login}" unless login =~ DELETED_REGEX
    update_attribute :email, "#{tag}#{email}" unless email =~ DELETED_REGEX
  end

  def rename_as_active
    login =~ DELETED_REGEX
    update_attribute :login, Regexp.last_match(1).to_s if login =~ DELETED_REGEX
    update_attribute :email, Regexp.last_match(1).to_s if email =~ DELETED_REGEX
  end

  def link_to_app(provider, profile)
    link = AppLink.new
    link.user              = self
    link.provider          = provider
    link.app_user_id       = profile[:id]
    link.custom_attributes = profile[:original]
    link.save!
  end

  def self.find_available_login(proposed_login = nil)
    proposed_login ||= "user"
    counter = 0
    begin
      counter += 1
      login = "#{proposed_login}#{counter == 1 ? nil : counter}"
    end while User.find_with_deleted(:first, :conditions => ["login LIKE ?", login])
    login
  end

  protected

    def find_available_deleted_tag
      counter = 0
      begin
        counter += 1
        tag = "#{DELETED_TAG}#{counter}__"
        user = User.find_with_deleted(:first,
                :conditions => "login LIKE '#{tag}#{login}' OR email LIKE '#{tag}#{email}'")
      end while user
      tag
    end

    def sanitize_name
      self.first_name = first_name.blank?? nil : first_name.squish
      self.last_name = last_name.blank?? nil : last_name.squish
    end

end
