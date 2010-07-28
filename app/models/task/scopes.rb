class Task
  named_scope :archived,   :conditions => ['status >= ?', 3], :include => [:project, :task_list, :assigned]
  named_scope :unarchived, :conditions => ['status <  ?', 3], :include => [:project, :task_list, :assigned]
  
  named_scope :active, :conditions => {:status => ACTIVE_STATUS_CODES}
  
  named_scope :assigned_to, lambda { |user|
    assigned_ids = user.people.from_unarchived.all(:select => 'people.id')
    { :conditions => {:assigned_id => assigned_ids} }
  }

  named_scope :due_today,
    :conditions => ["due_on = ? AND tasks.completed_at is null", 
                   Date.today], 
                  :include => :task_list
  
  named_scope :upcoming, 
    :conditions => ["due_on >= ? AND due_on <= ? AND tasks.completed_at is null", 
                   Date.today.monday, Date.today.monday + 2.weeks], 
                  :include => :task_list

  named_scope :upcoming_for_project, lambda {|project_id| {
    :conditions => ["tasks.due_on >= ? AND tasks.due_on <= ? AND task_lists.project_id = ? AND tasks.completed_at is null", 
                    Date.today.monday, Date.today.monday + 2.weeks, project_id], 
                    :include => :task_list }}
end