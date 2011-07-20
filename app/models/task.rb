class Task < RoleRecord
  include Immortal
  
  include Watchable

  STATUS_NAMES = [:new, :open, :hold, :resolved, :rejected]

  # values equal or bigger than :resolved will be considered as archived tasks
  STATUSES = STATUS_NAMES.each_with_index.each_with_object({}) {|(name, code), all| all[name] = code }

  ACTIVE_STATUS_CODES = [:new, :open].map { |name| STATUSES[name] }

  concerned_with :scopes, :callbacks, :conversions
  
  has_one  :first_comment, :class_name => 'Comment', :as => :target, :order => 'created_at ASC'
  has_many :recent_comments, :class_name => 'Comment', :as => :target, :order => 'created_at DESC', :limit => 2

  belongs_to :task_list, :counter_cache => true
  belongs_to :page

  belongs_to :assigned, :class_name => 'Person'
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy

  accepts_nested_attributes_for :comments, :allow_destroy => false,
    :reject_if => lambda { |comment| %w[body hours human_hours uploads_attributes google_docs_attributes].all? { |k| comment[k].blank? } }

  attr_accessible :name, :assigned_id, :status, :due_on, :comments_attributes

  validates_presence_of :name, :message => I18n.t('tasks.errors.name.cant_be_blank')
  validates_length_of   :name, :maximum => 255, :message => I18n.t('tasks.errors.name.too_long')
  validates_inclusion_of :status, :in => STATUSES.values, :message => "is not a valid status"
  
  validate :check_asignee_membership, :if => :assigned_id?
  
  # set by controller to indicate user that's doing task updating
  attr_accessor :updating_user
  attr_accessor :updating_date

  after_save :update_tasks_counts
  before_validation :copy_project_from_task_list, :if => lambda { |t| t.task_list_id? and not t.project_id? }
  before_save :set_comments_author, :if => :updating_user
  before_save :transition_from_new_to_open, :if => :assigned_id?
  before_save :save_changes_to_comment, :if => :track_changes?
  before_save :save_completed_at
  before_update :remember_comment_created
  
  def assigned
    @assigned ||= assigned_id ? Person.with_deleted.find_by_id(assigned_id) : nil
  end
  
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
    (Time.current.to_date - due_on).to_i
  end

  def overdue?
    !archived? && due_on && (Time.current.to_date > due_on)
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
  
  def refs_comments
    [first_comment, first_comment.try(:user)] +
     recent_comments + recent_comments.map(&:user)
  end

  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
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
      "#{story[:description]}\n\n<a href='#{story[:url]}'>View on #PT</a>"
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

    #If this is a new_record, use #save_changes_to_comment callback
    if track_changes?
      comments << Comment.new(:body => comment)
    else
      #use nested attributes
      self.comments_attributes = [{ :body => comment }]
    end

    save!
  end

  define_index do
    where "`tasks`.`deleted` = 0"

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
    # We should only ever execute this method once per callback cycle
    return if @saved_changes_to_comment

    comment = comments.detect(&:new_record?) || comments.build_by_user(updating_user)
    
    comment.project = project
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

    @saved_changes_to_comment = true
    true
  end

  def update_tasks_counts # after_save
    if assigned_id_changed? or status_changed? or self.new_record?
      [self.assigned_id, self.assigned_id_was].compact.each do |person_id|
        if person = Person.find_by_id(person_id)
          person.user.tasks_counts_update
        end
      end
    end
    true
  end

  def save_completed_at
    if [:resolved, :rejected].include? self.status_name
      self.completed_at = Time.current
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
