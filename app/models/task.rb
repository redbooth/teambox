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
    :reject_if => lambda { |comment| %w[is_private body hours human_hours uploads_attributes google_docs_attributes].all? { |k| comment[k].blank? } }

  attr_accessible :name, :assigned_id, :status, :due_on, :comments_attributes, :user, :task_list_id, :urgent

  validates_presence_of :user
  validates_presence_of :task_list
  validates_presence_of :name, :message => I18n.t('tasks.errors.name.cant_be_blank')
  validates_length_of   :name, :maximum => 255, :message => I18n.t('tasks.errors.name.too_long')
  validates_inclusion_of :status, :in => STATUSES.values, :message => "is not a valid status"
  
  validate :check_asignee_membership, :if => :assigned_id?
  validate :check_task_list, :on => :update
  
  # set by controller to indicate user that's doing task updating
  attr_accessor :updating_user
  attr_accessor :updating_date

  after_save :update_tasks_counts
  before_validation :nilize_assigned_id
  before_validation :set_comments_target
  before_validation :copy_project_from_task_list, :if => lambda { |t| t.task_list_id? and not t.project_id? }
  before_validation :set_comments_author, :if => :updating_user
  before_save :transition_from_new_to_open, :if => :assigned_id?
  before_save :save_changes_to_comment, :if => :track_changes?
  before_save :save_completed_at
  before_validation :remember_comment_created, :on => :update
  before_save :update_google_calendar_event, :if => lambda {|t| t.assigned.try(:user) || !t.google_calendar_url_token.blank? }
  before_validation :nilize_due_on_for_urgent_tasks
  
  def assigned
    @assigned ||= assigned_id ? Person.with_deleted.find_by_id(assigned_id) : nil
  end
  
  def track_changes?
    (new_record? and not status_new?) or
    (updating_user and (status_changed? or assigned_id_changed? or due_on_changed? or urgent_changed?))
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

  #we can rely on assigned_id being nil
  def assigned_id
    self[:assigned_id] == 0 ? nil : self[:assigned_id]
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

  def user
    @user ||= user_id ? User.with_deleted.find_by_id(user_id) : nil
  end
  
  def required_watcher_ids
    [user_id, assigned.try(:user_id)].compact
  end
  
  TRACKER_STATUS_MAP = {
    'unscheduled' => :new, 'started' => :open, 'delivered' => :hold, 'accepted' => :resolved, 'rejected' => :rejected
  }
  
  def update_from_pivotal_tracker(author, activity, version = :v2)
    story = nil
    if version == :v2
      story = activity[:stories][:story]
    elsif version == :v3
      story = activity[:stories].first
    else
      raise ArgumentError, "Unknown version for task from pivotal tracker"
    end
    
    author_name = activity[:author]
    self.updating_user = author || self.user

    comment = case activity[:event_type]
    when 'story_create'
      "#{story[:description]}\n\nView on PT: http://www.pivotaltracker.com/story/show/#{story[:id]}"
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
  
  def references
    refs = { :users => [user_id], :projects => [project_id], :task_list => [task_list_id] }
    refs[:people] = [assigned_id] if assigned_id
    refs[:comment] = [first_comment.try(:id)] + recent_comment_ids
    refs
  end
  
  def task_list_references
    refs = { :users => [user_id] }
    refs[:people] = [assigned_id] if assigned_id
    refs[:comment] = [first_comment.try(:id)] + recent_comment_ids
    refs
  end

  define_index do
    where Task.undeleted_clause_sql

    indexes name, :sortable => true

    indexes comments.body, :as => :body
    indexes comments.uploads(:asset_file_name), :as => :upload_name
    indexes comments.google_docs(:title), :as => :google_doc_name

    has project_id, created_at, updated_at
  end

  def is_visible?(user)
    !is_private or watchers.include? user
  end

  def force_google_calendar_event_creation!
    if self.google_calendar_url_token.blank?
      event = add_google_calendar_event
      self.save!
      event
    end
  end

  def delete_google_calendar_event!
    if !self.google_calendar_url_token.blank? && self.assigned && self.assigned.user
      begin
        gcal = self.assigned.user.get_calendar_app
        return if gcal.nil?

        calendar = self.assigned.user.google_calendar(gcal)
        return if calendar.nil?

        event = gcal.find_event(calendar.url_token, self.google_calendar_url_token)
        gcal.delete_event(event)
      rescue => e
        event = false
      ensure
        self.update_attribute(:google_calendar_url_token, nil)
      end
      event
    end
  end

  protected

  #don't store 0 when assigned_id was set by a string
  def nilize_assigned_id
    self[:assigned_id] = nil if assigned_id.to_i == 0
  end

  def check_asignee_membership
    unless project.people.include?(assigned)
      errors.add :assigned, :doesnt_belong
    end
  end
  
  def check_task_list
    if task_list_id_changed?
      old_task_list = TaskList.find_by_id(task_list_id_was)
      new_task_list = TaskList.find_by_id(task_list_id)
      
      if old_task_list.project_id != new_task_list.project_id
        errors.add :task_list_id, "Task list belongs to a different project"
      end
    end
  end
  
  def set_comments_author # before_save
    comments.select(&:new_record?).each do |comment|
      comment.user = updating_user
    end
    true
  end
  
  def remember_comment_created # before_update
    @comment_created = comments.any?(&:new_record?) || assigned_id_changed? || status_changed? || due_on_changed? || urgent_changed?
    true
  end
  
  def set_comments_target
    comments.each{|c| c.target = self if c.target.nil? or c.new_record? }
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

    if urgent_changed? or self.new_record?
      comment.urgent = self.urgent
      comment.previous_urgent = self.urgent_was if urgent_changed?
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
  
  def to_google_calendar_event
    GoogleCalendar::Event.new(options_for_google_calendar_event)
  end
  
  def options_for_google_calendar_event
    {
      :title => "#{self.name} (#{self.project.name} - #{self.task_list.name})",
      :details => "#{self.comments.first.try(:body)}\r\n\r\n#{"https://#{Teambox.config.app_domain}/projects/#{self.project.permalink}/tasks/#{self.id}"}",
      :start => self.due_on,
      :end => self.due_on
    }
  end
  
  def update_calendar_event(calendar_entry)
    calendar_entry.title = self.name if self.name_changed?
    calendar_entry.start = self.due_on if self.due_on_changed?
    calendar_entry.end = self.due_on if self.due_on_changed?
  end
  
  def update_google_calendar_event
    begin
      do_calendar_update
    rescue => e
      Rails.logger.warn "[GCal] Cannot perform google calendar event #{e.message}"
      Rails.logger.warn e.backtrace
    end
  end
  
  def do_calendar_update
    unless self.name_changed? || self.due_on_changed? || self.assigned_id_changed? || self.status_changed?
      Rails.logger.info "[GCal] Not updating google calendar as nothing we care about has changed"
      return
    else
      Rails.logger.info "[GCal] Google cal task changed? name:#{self.name_changed?} || due_on:#{self.due_on_changed?} || assigned:#{self.assigned_id_changed?} || status:#{self.status_changed?}"
    end
    
    if !self.google_calendar_url_token.blank?
      delete_old_events_if_required
    end
    
    add_google_calendar_event
  end

  def add_google_calendar_event
    # Perform the main add action if this calendar is suitable
    if self.assigned && self.assigned.user && !self.due_on.nil? && self.open?
      gcal = self.assigned.user.get_calendar_app
      return if gcal.nil?
      
      calendar = self.assigned.user.google_calendar(gcal)
      return if calendar.nil?
      
      if self.google_calendar_url_token.blank? # Create a new calendar entry
        Rails.logger.info "[GCal] Creating new google calendar entry"
        event = gcal.create_event(calendar.url_token, self.to_google_calendar_event)
        self.google_calendar_url_token = event.url_token
        event
      else # Update the exsiting entry with the new details
        Rails.logger.info "[GCal] Updating exsisting google calendar entry"
        event = gcal.find_event(calendar.url_token, self.google_calendar_url_token)
        update_calendar_event(event)
        gcal.update_event(event)
      end
    end
  end
  
  def delete_old_events_if_required
    Rails.logger.info "[GCal] Deleting old events if required"
    
    if !self.new_record? && self.assigned_id_changed? && !self.assigned_id_was.blank?
      # We need to remove the calendar entry from the old user if they exist
      Rails.logger.info "[GCal] Assigned user changed from #{self.assigned_id_was.inspect} to #{self.assigned_id.inspect}"
    
      old_person = Person.find(self.assigned_id_was)
      return if old_person.nil?
    
      gcal = old_person.user.get_calendar_app
      return if gcal.nil?
    
      calendar = old_person.user.google_calendar(gcal)
      return if calendar.nil?
    
      event = gcal.find_event(calendar.url_token, self.google_calendar_url_token)
      gcal.delete_event(event)
      self.google_calendar_url_token = nil
    end
  
    if !self.new_record? && ((self.due_on_changed? && self.due_on.blank? && !self.due_on_was.blank?) || (self.status_changed? && !self.open?))
      # We need to remove the calendar entry the user as it no longer has a due date or is no longer open
      Rails.logger.info "[GCal] Due on changed from #{self.due_on_was.inspect} to #{self.due_on.inspect}" if self.due_on_changed?
      Rails.logger.info "[GCal] Status changed from #{self.status_was.inspect} to #{self.status.inspect}" if self.status_changed?
    
      gcal = self.assigned.user.get_calendar_app
      return if gcal.nil?
    
      calendar = self.assigned.user.google_calendar(gcal)
      return if calendar.nil?
    
      event = gcal.find_event(calendar.url_token, self.google_calendar_url_token)
      gcal.delete_event(event)
      self.google_calendar_url_token = nil
    end
  end

  def nilize_due_on_for_urgent_tasks
    self.due_on = nil if self.urgent?
  end  
end
