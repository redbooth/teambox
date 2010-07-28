class User
  def self.send_daily_task_reminders
    hour = Teambox.config.daily_task_reminder_email_time.to_i
    zones = ActiveSupport::TimeZone.all.select {|tz| tz.now.hour == hour}
    # don't send on weekends
    return if [0, 6].include?(zones.first.today.wday)
    
    self.wants_task_reminder_email.in_time_zone(zones.map(&:name)).find_each do |user|
      if user.assigned_tasks.any?
        Emailer.deliver_daily_task_reminder(user)
      end
    end
  end

  def assigned_tasks
    Task.active.assigned_to(self)
  end

  def tasks_for_daily_reminder_email
    tasks = assigned_tasks.all(:order => 'tasks.due_on')
    tasks_by_dueness = Hash.new { |h, k| h[k] = Array.new }
    
    tasks.each_with_object(tasks_by_dueness) do |task, all|
      due_identifier = if Date.today == task.due_on
        :today
      elsif Date.today + 1 == task.due_on
        :tomorrow
      elsif task.due_on > Date.today and task.due_on < Date.today + 15
        :for_next_two_weeks
      elsif Date.today > task.due_on
        :late
      else
        :no_due_date
      end
      
      all[due_identifier] << task
    end
  end
end