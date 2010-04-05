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
                  :due_on,
                  :body

  attr_accessor :previous_status, :previous_assigned_id, :body

  # IDs equal or bigger than :resolved will be considered as archived tasks
  STATUSES = {:new => 0, :open => 1, :hold => 2, :resolved => 3, :rejected => 4}

  ACTIVE_STATUS_NAMES = [ :new, :open ]
  ACTIVE_STATUS_CODES = ACTIVE_STATUS_NAMES.map { |status_name| STATUSES[status_name] }

  def archived?
    [STATUSES[:rejected],STATUSES[:resolved]].include?(status)
  end

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

  def status_name
    key = nil
    STATUSES.each{|k,v| key = k.to_s if status.to_i == v.to_i }
    key
  end

  def assigned?
    !assigned.nil?
  end

  def assigned_to?(u)
    assigned.try(:user_id) == u.id
  end

  def assign_to(u)
    self.assigned = u.in_project(self.project)
    save(false)
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

  def user
    User.find_with_deleted(user_id)
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
end