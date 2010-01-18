Given /^the task called "([^\"]*)" is due today$/ do |name|
  Task.find_by_name(name).update_attribute(:due_on, Date.today)
end

Then /^when the daily reminders for tasks are sent$/ do
  User.send_daily_task_reminders
end