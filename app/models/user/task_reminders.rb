class User
  def self.send_daily_task_reminders
    send_at_hour = Teambox.config.daily_task_reminder_email_time.to_i
    now = Time.now
    
    # find timezones which are currently at the right hour
    zones = ActiveSupport::TimeZone.all.select {|tz|
      now.in_time_zone(tz).hour == send_at_hour
    }
    # don't send on weekends
    return if [0, 6].include?(zones.first.today.wday)
    
    self.wants_task_reminder_email.in_time_zone(zones.map(&:name)).find_each do |user|
      if user.assigned_tasks.due_sooner_than_two_weeks.any?
        Emailer.send_with_language :daily_task_reminder, user.locale.to_sym, user.id
      end
    end
  end

  # scopes to tasks which are late or due inside the next 2 weeks
  def assigned_tasks(max_date = nil)
    Task.active.assigned_to(self)
  end

  # never contains tasks without a due date
  def tasks_for_daily_reminder_email
    tasks = assigned_tasks.due_sooner_than_two_weeks.all(:order => 'tasks.due_on')
    tasks_by_dueness = Hash.new { |h, k| h[k] = Array.new }

    tasks_with_date = tasks.each_with_object(tasks_by_dueness) do |task, all|
      due_identifier = if Date.today == task.due_on
        :today
      elsif Date.today + 1 == task.due_on
        :tomorrow
      elsif Date.today > task.due_on
        :late
      else
        :for_next_two_weeks
      end

      all[due_identifier] << task
    end
    tasks_with_date[:urgent] = assigned_tasks.urgent
    tasks_with_date
  end
end
