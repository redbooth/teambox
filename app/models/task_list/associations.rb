class TaskList
  belongs_to :page
  has_many :tasks, :order => 'position', :dependent => :destroy
  has_many :comments, :as => :target, :order => 'created_at DESC', :dependent => :destroy
  
  has_one  :first_comment, :class_name => 'Comment', :as => :target, :order => 'created_at ASC'
  has_many :recent_comments, :class_name => 'Comment', :as => :target, :order => 'created_at DESC', :limit => 2
  
  has_many :archived_tasks, :class_name => 'Task', :order => 'position', :conditions => ['status >= ?', 3], :include => [:project, :task_list, :assigned]
  has_many :unarchived_tasks, :class_name => 'Task', :order => 'position', :conditions => ['status <  ?', 3], :include => [:project, :task_list, :assigned]
end