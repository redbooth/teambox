class User
  named_scope :in_time_zone, lambda {|zones|
    { :conditions => ['time_zone IN (?)', zones] }
  }

  named_scope :wants_task_reminder_email, :conditions => { :wants_task_reminder => true }
  named_scope :wants_task_notifications, :conditions => { :notify_tasks => true }
  named_scope :confirmed, :conditions =>  { :confirmed_user => true }
end