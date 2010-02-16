Given /^the daily task reminder emails are set to be sent at "([^\"]*)"$/ do |time|
  APP_CONFIG["daily_task_reminder_email_time"] = time
end

When /^the daily task reminders go out$/ do
  User.send_daily_task_reminders
end

When /^the daily task reminders go out at "([^\"]*)"$/ do |hour_|
  new_time = Time.parse(hour_)
  Time.zone.stub!(:now).and_return(new_time)
  User.send_daily_task_reminders
end