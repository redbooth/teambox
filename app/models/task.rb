class Task < RoleRecord
  
  include Watchable

  STATUS_NAMES = [:new, :open, :hold, :resolved, :rejected]

  # values equal or bigger than :resolved will be considered as archived tasks
  STATUSES = STATUS_NAMES.each_with_index.each_with_object({}) {|(name, code), all| all[name] = code }

  ACTIVE_STATUS_CODES = [:new, :open].map { |name| STATUSES[name] }

  concerned_with :scopes, :callbacks

  belongs_to :task_list, :counter_cache => true
  belongs_to :page
  belongs_to :assigned, :class_name => 'Person'
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy

  accepts_nested_attributes_for :comments, :allow_destroy => false,
    :reject_if => lambda { |comment| %w[body hours human_hours].all? { |k| comment[k].blank? } }

  acts_as_list :scope => :task_list

  attr_accessible :name, :assigned_id, :status, :due_on, :comments_attributes

  validates_presence_of :name, :message => I18n.t('tasks.errors.name.cant_be_blank')
  validates_length_of   :name, :maximum => 255, :message => I18n.t('tasks.errors.name.too_long')
  
  validate :check_asignee_membership, :if => :assigned_id?
  
  # set by controller to indicate user that's doing task updating
  attr_accessor :updating_user
  
  before_validation :copy_project_from_task_list, :if => lambda { |t| t.task_list_id? and not t.project_id? }
  before_save :set_comments_author, :if => :updating_user
  before_save :save_changes_to_comment, :if => :track_changes?
  
  def track_changes?
    updating_user and (status_changed? or assigned_id_changed?)
  end

  def archived?
    [:rejected, :resolved].include? status_name
  end
  alias :closed? :archived?

  def status_new?
    status_name == :new
  end

  def open?
    status_name == :open
  end

  def active?
    status_new? or open?
  end

  def status_name
    STATUS_NAMES[status]
  end
  
  def status_name=(value)
    self.status = STATUS_NAMES.index(value)
  end

  # TODO: investigate if we can trash these two
  def assigned?
    !assigned.nil?
  end
  
  def unassigned?
    !assigned
  end

  def assigned_to?(user)
    assigned and assigned.user_id == user.id
  end

  def assign_to(user)
    self.update_attribute :assigned, user.in_project(project)
  end

  def overdue
    (Time.now.to_date - due_on).to_i
  end

  def overdue?
    !archived? && due_on && (Time.now.to_date > due_on)
  end

  def due_today?
    due_on == Time.current.to_date
  end

  def due_tomorrow?
    due_on == (Time.current + 1.day).to_date
  end
  
  def total_hours
    comments.sum('hours')
  end

  def after_comment(comment)
    if comment.status == 0 && self.assigned_id != nil
      self.status, comment.status = 1,1
    end
    self.save!
  end

  def notify_new_comment(comment)
    self.watchers.each do |user|
      if user != comment.user and user.notify_tasks
        Emailer.send_with_language(:notify_task, user.locale, user, self.project, self) # deliver_notify_task
      end
    end
  end

  def to_s
    name
  end

  def user
    user_id && User.find_with_deleted(user_id)
  end

  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.task :id => id do
      xml.tag! 'project-id',      project_id
      xml.tag! 'user-id',         user_id
      xml.tag! 'name',            name
      xml.tag! 'position',        position
      xml.tag! 'comments-count',  comments_count
      xml.tag! 'assigned-id',     assigned_id
      xml.tag! 'status',          status
      xml.tag! 'due-on',          due_on.to_s(:db) if due_on
      xml.tag! 'created-at',      created_at.to_s(:db)
      xml.tag! 'updated-at',      updated_at.to_s(:db)
      xml.tag! 'completed-at',    completed_at.to_s(:db) if completed_at
      xml.tag! 'watchers',        Array.wrap(watchers_ids).join(',')
      unless Array(options[:include]).include? :tasks
        task_list.to_xml(options.merge({ :skip_instruct => true }))
      end
    end
  end
  
  def to_api_hash(options = {})
    base = {
      :id => id,
      :project_id => project_id,
      :task_list_id => task_list_id,
      :user_id => user_id,
      :name => name,
      :position => position,
      :comments_count => comments_count,
      :assigned_id => assigned_id,
      :status => status,
      :created_at => created_at.to_s(:db),
      :updated_at => updated_at.to_s(:db),
      :watchers => Array.wrap(watchers_ids)
    }
    
    base[:due_on] = due_on.to_s(:db) if due_on
    base[:completed_at] = completed_at.to_s(:db) if completed_at
    
    if Array(options[:include]).include? :task_list
      base[:task_list] = task_list.to_api_hash(options)
    end
    
    base
  end
  
  def to_json(options = {})
    to_api_hash(options).to_json
  end
  
  protected
  
  def check_asignee_membership
    unless project.people.include?(assigned)
      errors.add :assigned, :doesnt_belong
    end
  end
  
  def set_comments_author # before_save
    comments.select(&:new_record?).each do |comment|
      comment.user = updating_user
    end
    true
  end

  def save_changes_to_comment # before_save
    comment = comments.detect(&:new_record?) || comments.build_by_user(updating_user)
    
    if status_changed?
      comment.status = self.status
      comment.previous_status = self.status_was
    end
    
    if assigned_id_changed?
      comment.assigned_id = self.assigned_id
      comment.previous_assigned_id = self.assigned_id_was
    end
    true
  end
  
  def copy_project_from_task_list
    self.project_id = task_list.project_id
  end
end