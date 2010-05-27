class TaskList
  default_scope :order => 'position ASC, created_at DESC'
  named_scope :with_archived_tasks, :conditions => 'archived_tasks_count > 0'
  named_scope :archived, :conditions => {:archived => true}
  named_scope :unarchived, :conditions => {:archived => false}
end