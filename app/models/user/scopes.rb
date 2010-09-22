class User
  named_scope :in_time_zone, lambda { |zone|
    { :conditions => {:time_zone => zone} }
  }

  named_scope :wants_task_reminder_email, :conditions => { :wants_task_reminder => true }
  named_scope :wants_task_notifications, :conditions => { :notify_tasks => true }
  named_scope :confirmed, :conditions =>  { :confirmed_user => true }
end