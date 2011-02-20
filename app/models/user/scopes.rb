class User
  scope :in_time_zone, lambda { |zone|
    { :conditions => {:time_zone => zone} }
  }

  scope :wants_task_reminder_email, :conditions => { :wants_task_reminder => true }
  scope :wants_task_notifications, :conditions => { :notify_tasks => true }
  scope :confirmed, :conditions =>  { :confirmed_user => true }
end