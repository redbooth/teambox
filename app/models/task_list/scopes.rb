class TaskList
  default_scope :order => 'position ASC, created_at DESC'
  scope :with_archived_tasks, :conditions => 'archived_tasks_count > 0'
  scope :archived, :conditions => {:archived => true}
  scope :unarchived, :conditions => {:archived => false}
end