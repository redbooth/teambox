class Task < RoleRecord
  
  default_scope :order => 'created_at DESC'

  serialize :watchers_ids

  belongs_to :task_list,  :counter_cache => true
  belongs_to :page
  belongs_to :assigned, :class_name => 'Person'

  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy
  
  acts_as_list :scope => :task_list

  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}
  named_scope :assigned_to, lambda { |person_id| { :conditions => ['assigned_id > ?', person_id] } }
  
  validates_length_of :name, :within => 1..255
  
  validates_each :assigned do |record, attr, value|
    if value and not record.project.people.include?(value)
      record.errors.add attr, "doesn't belong to the project"
    end
  end

  attr_accessible :name, :assigned_id, :status, :due_on

  STATUSES = ['new','open','hold','resolved','rejected']

  def status_name
    Task::STATUSES[status.to_i].underscore
  end

  def after_create
    self.add_watcher(self.user)
  end

  def before_save
    unless position
      last_position = self.task_list.tasks.first(:select => 'position')
      self.position = last_position.nil? ? 1 : last_position.position.succ
    end
    if self.watchers_ids and assigned and assigned.user and not self.watchers_ids.include?(assigned.user.id)
      self.add_watcher(assigned.user)
    end
  end

  def after_save
    self.update_counter_cache
  end

  def update_counter_cache
    self.task_list.archived_tasks_count = Task.count(:conditions => { :archived => true, :task_list_id => self.task_list.id })
    self.task_list.save
  end
  
  def after_destroy
    Activity.destroy_all  :target_id => self.id, :target_type => self.class.to_s
    Comment.destroy_all   :target_id => self.id, :target_type => self.class.to_s
    self.update_counter_cache
  end

  def assigned?(u)
    assigned.user.id == u.id if assigned
  end
  
  def overdue
    (Time.now.to_date - due_on).to_i
  end
  
  def overdue?
    due_on ? Time.now.to_date > due_on : false
  end

  def unassigned?
    !assigned
  end
    
  def open?
    status == 1
  end
  
  def closed?
    [3,4].include?(status)
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

  def after_comment(comment)
    notify_new_comment
  end
  
  def notify_new_comment
    comment ||= self.comments.last
    self.watchers.each do |user|
      unless user == comment.user
        Emailer.deliver_notify_task(user, self.project, self)
      end
    end
  end
end