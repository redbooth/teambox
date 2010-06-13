require 'digest/sha1'
require 'time_zone'

# A User model describes an actual user, with his password and personal info.
# A Person model describes the relationship of a User that follows a Project.

class User < ActiveRecord::Base

  include ActionController::UrlWriter
  extend TimeZone

  acts_as_paranoid
  concerned_with  :activation,
                  :avatar,
                  :authentication,
                  :example_project,
                  :recent_projects,
                  :roles,
                  :rss,
                  :scopes,
                  :validation

  # After adding a new locale, run "rake import:country_select 'de'" where de is your locale.
  LANGUAGES = [['English',     'en'],
               ['Español',     'es'],
               ['Português',   'pt'],
               ['Français',    'fr'],
               ['Deutsch',     'de'],
               ['Català',      'ca'],
               ['Italiano',    'it'],
               ['Русский',     'ru'],
               ['Chinese',     'zh'],
               ['Japanese',    'ja'],
               ['Nederlands',  'nl'],
               ['Slovenščina', 'si']
               ]

  LANGUAGE_CODES = LANGUAGES.map { |lang| lang[1] }

  has_many :projects_owned, :class_name => 'Project', :foreign_key => 'user_id'
  has_many :comments
  has_many :people
  has_many :projects, :through => :people, :order => 'name ASC'
  has_many :invitations, :foreign_key => 'invited_user_id'
  has_many :activities
  has_many :uploads
  has_many :app_links
  has_many :hooks, :dependent => :destroy
  has_one :group
  has_and_belongs_to_many :groups

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
                  :first_day_of_week,
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
  
  def language
    if LANGUAGE_CODES.include? self[:language]
      self[:language]
    else
      LANGUAGES.first[1]
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

  def update_visited_at
    if visited_at.nil? or (Time.now - visited_at) >= 12.hours
      update_attribute(:visited_at, Time.now)
    end
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
      xml.tag! 'language', language
      xml.tag! 'username', login
      xml.tag! 'time_zone', time_zone
      xml.tag! 'biography', biography
      xml.tag! 'created-at', created_at.to_s(:db)
      xml.tag! 'updated-at', updated_at.to_s(:db)
      xml.tag! 'avatar-url', avatar_or_gravatar_url(:thumb)
    end
  end

  def self.send_daily_task_reminders
    tzs = time_zones_to_send_daily_task_reminders_to
    in_time_zone(tzs.map(&:name)).wants_task_reminder_email.each do |user|
      tasks = user.tasks_for_daily_reminder_email
      Emailer.deliver_daily_task_reminder(user, tasks) unless tasks.values.flatten.empty?
    end
  end

  def self.time_zones_to_send_daily_task_reminders_to
    sending_hour = Time.parse(Teambox.config.daily_task_reminder_email_time).hour
    time_zones_with_time(sending_hour)
  end

  def assigned_tasks(project_filter)
    people.reject{ |r| r.project.archived? }.map { |person| person.project.tasks }.flatten.
      select { |task| task.active? }.
      select { |task| task.assigned_to?(self) }.
      sort { |a,b| (a.due_on || 1.year.from_now.to_date) <=> (b.due_on || 1.year.from_now.to_date) }
  end

  def assigned_tasks_count
    people.reject{ |r| r.project.archived? }.map { |person| person.project.tasks }.flatten.
      select { |task| task.active? && task.assigned_to?(self) }.size
  end

  def tasks_for_daily_reminder_email
    return {} if [0, 6].include?(Date.today.wday)
    assigned_tasks = assigned_tasks(:all)
    tasks_without_due_date, tasks_with_due_date  = assigned_tasks.partition { |task| task.due_on.nil? }
    tasks_by_dueness = tasks_with_due_date.inject({}) do |tasks, task|
      if Date.today == task.due_on
        tasks[:today] ||= []
        tasks[:today].push(task)
      elsif Date.today + 1 == task.due_on
        tasks[:tomorrow] ||= []
        tasks[:tomorrow].push(task)
      elsif task.due_on > Date.today and task.due_on < Date.today + 15
        tasks[:for_next_two_weeks] ||= []
        tasks[:for_next_two_weeks].push(task)
      elsif Date.today > task.due_on
        tasks[:late] ||= []
        tasks[:late].push(task)
      end
      tasks
    end
    if !tasks_by_dueness.values.flatten.empty? || [1, 4].include?(Date.today.wday)
      tasks_by_dueness[:no_due_date] = tasks_without_due_date
    end
    tasks_by_dueness
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
