class Task < RoleRecord

  concerned_with :validation,
                 :scopes,
                 :associations,
                 :callbacks

  serialize :watchers_ids

  acts_as_list :scope => :task_list

  attr_accessible :name,
                  :assigned_id,
                  :previous_status,
                  :previous_assigned_id,
                  :status,
                  :due_on

  attr_accessor :previous_status, :previous_assigned_id

  STATUSES = {:new => 0, :open => 1, :hold => 2, :resolved => 3, :rejected => 4}

  ACTIVE_STATUS_NAMES = [ :new, :open ]
  ACTIVE_STATUS_CODES = ACTIVE_STATUS_NAMES.map { |status_name| STATUSES[status_name] }

  def status_new?
    STATUSES[:new] == status
  end

  def open?
    STATUSES[:open] == status
  end

  def active?
    ACTIVE_STATUS_CODES.include?(status)
  end

  def closed?
    [STATUSES[:rejected],STATUSES[:resolved]].include?(status)
  end

  def reopen
    self.status = Task::STATUSES[:open]
    self.archived = false
  end

  def status_name
    key = nil
    STATUSES.each{|k,v| key = k.to_s if status.to_i == v.to_i }
    key
  end

  def update_counter_cache
    self.task_list.archived_tasks_count = Task.count(:conditions => { :archived => true, :task_list_id => self.task_list.id })
    self.task_list.save
  end

  def assigned?
    !assigned.nil?
  end

  def assigned_to?(u)
    assigned.user.id == u.id if assigned?
  end

  def assign_to(u)
    self.assigned = u.in_project(self.project)
    save(false)
  end

  def overdue
    (Time.now.to_date - due_on).to_i
  end

  def overdue?
    due_on ? Time.now.to_date > due_on : false
  end

  def due_today?
    due_on == Time.current.to_date
  end

  def due_tomorrow?
    due_on == (Time.current + 1.day).to_date
  end

  def unassigned?
    !assigned
  end

  def comments_count
    read_attribute(:comments_count) || 0
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
        Emailer.send_with_language(:notify_task, user.language, user, self.project, self) # deliver_notify_task
      end
    end
    self.sync_watchers
  end

  def to_s
    name
  end
  
  def to_ical_event
    if due_on
      event = Icalendar::Event.new
      date = due_on.to_date
      event.klass       project.name
      event.dtstart     Date.new(date.year, date.month, date.day)
      event.summary     name
      event.description ""
      event.location    ""
      event.dtstamp     created_at
      #event.url         project_task_list_task_url(project, task_list, self)
      event.uid         "task-#{id}"
      event
    end
  end
  

  def user
    User.find_with_deleted(user_id)
  end

end