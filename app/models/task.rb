class Task < RoleRecord
  
  include Watchable

  STATUS_NAMES = [:new, :open, :hold, :resolved, :rejected]

  # values equal or bigger than :resolved will be considered as archived tasks
  STATUSES = STATUS_NAMES.each_with_index.each_with_object({}) {|(name, code), all| all[name] = code }

  ACTIVE_STATUS_CODES = [:new, :open].map { |name| STATUSES[name] }

  concerned_with :scopes, :callbacks

  belongs_to :task_list, :counter_cache => true
  belongs_to :page
  belongs_to :assigned, :class_name => 'Person', :with_deleted => true
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy

  accepts_nested_attributes_for :comments, :allow_destroy => false,
    :reject_if => lambda { |comment| %w[body hours human_hours uploads_attributes].all? { |k| comment[k].blank? } }

  attr_accessible :name, :assigned_id, :status, :due_on, :comments_attributes

  validates_presence_of :name, :message => I18n.t('tasks.errors.name.cant_be_blank')
  validates_length_of   :name, :maximum => 255, :message => I18n.t('tasks.errors.name.too_long')
  validates_inclusion_of :status, :in => STATUSES.values, :message => "is not a valid status"
  
  validate :check_asignee_membership, :if => :assigned_id?
  
  # set by controller to indicate user that's doing task updating
  attr_accessor :updating_user
  attr_accessor :updating_date
  
  before_validation :copy_project_from_task_list, :if => lambda { |t| t.task_list_id? and not t.project_id? }
  before_save :set_comments_author, :if => :updating_user
  before_save :transition_from_new_to_open, :if => :assigned_id?
  before_save :save_changes_to_comment, :if => :track_changes?
  before_save :save_completed_at
  before_update :remember_comment_created
  
  def track_changes?
    (new_record? and not status_new?) or
    (updating_user and (status_changed? or assigned_id_changed? or due_on_changed?))
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
    status ? STATUS_NAMES[status] : :new
  end
  
  def status_name=(value)
    status_code = STATUS_NAMES.index(value.to_sym)
    raise ArgumentError, "invalid status: #{value.inspect}" if status_code.nil?
    self.status = status_code
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
  
  def comment_created?
    !!@comment_created
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
  
  def due_in?(time_end)
    due_on && due_on >= Time.current.to_date && due_on < (Time.current+time_end).to_date
  end
  
  def total_hours
    comments.sum('hours')
  end

  def to_s
    name
  end

  def user
    user_id && User.find_with_deleted(user_id)
  end
  
  TRACKER_STATUS_MAP = {
    'started' => :open, 'delivered' => :hold, 'accepted' => :resolved, 'rejected' => :rejected
  }
  
  def update_from_pivotal_tracker(author, activity)
    story = activity[:stories][:story]
    author_name = activity[:author]
    self.updating_user = author || self.user

    comment = case activity[:event_type]
    when 'story_create'
      "#{story[:description]}\n\n<a href=http://www.pivotaltracker.com/story/show/#{story[:id]}>View on #PT</a>"
    when 'story_update'
      if story[:current_state]
        # TODO: setting assigned person all the time might not be what we want
        self.assigned = author.in_project(self.project) if author
        # status changes
        if new_status = TRACKER_STATUS_MAP[story[:current_state]]
          self.status_name = new_status
        else
          Rails.logger.warn "[Pivotal Tracker] unknown state: #{story[:current_state].inspect}"
        end

        if author
          "I marked the task as #{story[:current_state]} on #PT"
        else
          "#{author_name} marked the task as #{story[:current_state]} on #PT"
        end
      elsif story[:description]
        # Changing description
        "Task description is now: #{story[:description]} #PT"
      else
        # Other activity types
        "#{activity[:description]} #PT"
      end
    when 'story_delete'
      self.status_name = :rejected
      "#{author ? 'I' : author_name} deleted this story on #PT"
    when 'note_create'
      text = story[:notes][:note][:text]
      if author
        "#{text} #PT"
      else
        "#{author_name} commented on #PT: '#{text}'"
      end
    else
      "#{activity[:description]} #PT"
    end
    
    self.comments_attributes = [{ :body => comment }]
    save!
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
      :created_at => created_at.to_s(:api_time),
      :updated_at => updated_at.to_s(:api_time),
      :watchers => Array.wrap(watchers_ids)
    }
    
    base[:type] = self.class.to_s if options[:emit_type]
    base[:due_on] = due_on.to_s(:db) if due_on
    base[:completed_at] = completed_at.to_s(:db) if completed_at
    
    if Array(options[:include]).include? :task_list
      base[:task_list] = task_list.to_api_hash(options)
    end
    
    if Array(options[:include]).include? :assigned
      base[:assigned] = assigned.to_api_hash(:include => :user) if assigned
    end
    
    if Array(options[:include]).include? :user
      base[:user] = {
        :username => user.login,
        :first_name => user.first_name,
        :last_name => user.last_name,
        :avatar_url => user.avatar_or_gravatar_url(:thumb)
      }
    end
    
    base
  end

  define_index do
    where "`tasks`.`deleted_at` IS NULL"

    indexes name, :sortable => true

    indexes comments.body, :as => :body
    indexes comments.user.first_name, :as => :user_first_name
    indexes comments.user.last_name, :as => :user_last_name
    indexes comments.uploads(:asset_file_name), :as => :upload_name

    has project_id, created_at, updated_at
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
  
  def remember_comment_created # before_update
    @comment_created = comments.any?(&:new_record?)
    true
  end

  def save_changes_to_comment # before_save
    comment = comments.detect(&:new_record?) || comments.build_by_user(updating_user)
    
    comment.created_at = @updating_date if @updating_date
    
    if status_changed? or self.new_record?
      comment.status = self.status
      comment.previous_status = self.status_was if status_changed?
    end
    
    if assigned_id_changed? or self.new_record?
      comment.assigned_id = self.assigned_id
      comment.previous_assigned_id = self.assigned_id_was if assigned_id_changed?
    end

    if due_on_changed? or self.new_record?
      comment.due_on = self.due_on
      comment.previous_due_on = self.due_on_was if due_on_changed?
    end
    true
  end

  def save_completed_at
    if [:resolved, :rejected].include? self.status_name
      self.completed_at = Time.now
    else
      self.completed_at = nil
    end if status_changed? or self.new_record?
  end

  def copy_project_from_task_list
    self.project_id = task_list.project_id
  end
  
  def transition_from_new_to_open # before_save
    self.status_name = :open if self.status_name == :new
  end
end
