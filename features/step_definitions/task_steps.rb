Given /^the task called "([^\"]*)" is due today$/ do |name|
  Task.find_by_name(name).update_attribute(:due_on, Date.today)
end

Given /^there is a task called "([^\"]*)"$/ do |name|
  Task.find_by_name(name) || Factory(:task, :name => name)
end

Given /^the task called "([^\"]*)" is assigned to me$/ do |name|
  Given %(there is a task called "#{name}")
  task = Task.find_by_name(name)
  task.project.add_user(@current_user)
  task.assign_to(@user)
end

Then /^when the daily reminders for tasks are sent$/ do
  User.send_daily_task_reminders
end