class Task
  default_scope :order => 'position ASC, created_at DESC'

  scope :archived,   :conditions => ['status >= ?', 3], :include => [:project, :task_list, :assigned]
  scope :unarchived, :conditions => ['status <  ?', 3], :include => [:project, :task_list, :assigned]
  
  scope :active, :conditions => {:status => ACTIVE_STATUS_CODES}
  
  scope :assigned_to, lambda { |user|
    people = user.people.from_unarchived.all(:select => 'people.id')
    { :conditions => {:assigned_id => people} }
  }
  
  scope :due_sooner_than_two_weeks, lambda {
    { :conditions => ['tasks.due_on < ?', 2.weeks.from_now] }
  }

  scope :due_today,
    :conditions => ["due_on = ? AND tasks.completed_at is null", 
                   Date.today], 
                  :include => :task_list
  
  scope :upcoming, 
    :conditions => ["due_on >= ? AND due_on <= ? AND tasks.completed_at is null", 
                   Date.today.monday, Date.today.monday + 2.weeks], 
                  :include => :task_list

  scope :upcoming_for_project, lambda {|project_id| {
    :conditions => ["tasks.due_on >= ? AND tasks.due_on <= ? AND task_lists.project_id = ? AND tasks.completed_at is null", 
                    Date.today.monday, Date.today.monday + 2.weeks, project_id], 
                    :include => :task_list }}
  
  scope :from_pivotal_tracker, lambda { |story_id|
    { :conditions => ['name LIKE ?', "%[PT#{story_id}]%"] }
  }
end