class TaskList < RoleRecord
  default_scope :order => 'created_at DESC'

  belongs_to :page
  
  has_many :tasks, :order => 'position', :dependent => :destroy
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy

  named_scope :with_archived_tasks, :conditions => 'archived_tasks_count > 0'
  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}
  
  acts_as_list :scope => :project
  attr_accessible :name, :start_on, :finish_on

  validates_presence_of :name, :message => I18n.t('task_lists.errors.name.cant_be_blank')
  validates_length_of   :name, :maximum => 255, :message => I18n.t('task_lists.errors.name.too_long')
  
  serialize :watchers_ids

  def new_task(user, task=nil)
    self.tasks.new(task) do |task|
      task.project_id = self.project_id
      task.user_id = user.id
    end
  end
  
  def before_save
    unless self.position
      first_task_list = self.project.task_lists.first(:select => 'position')
      if first_task_list
        last_position = first_task_list.position
        self.position = last_position.nil? ? 1 : last_position.succ
      else
        self.position = 0
      end
    end
  end
      
  def after_create
    self.project.log_activity(self,'create')
    self.add_watcher(self.user) 
  end

  def after_comment(comment)
    notify_new_comment(comment)
  end
  
  def notify_new_comment(comment)
    self.watchers.each do |user|
      if user != comment.user and user.notify_task_lists
        Emailer.deliver_notify_task_list(user, self.project, self)
      end
    end
  end
end