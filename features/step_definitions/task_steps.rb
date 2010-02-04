Given /^there is a task called "([^\"]*)"$/ do |name|
  Task.find_by_name(name) || Factory(:task, :name => name)
end

Given /^the task called "([^\"]*)" belongs to the task list called "([^\"]*)"$/ do |task_name, task_list_name|
  Given %(there is a task called "#{task_name}")
  Given %(there is a task list called "#{task_list_name}")
  task_list = TaskList.find_by_name(task_list_name)
  Task.find_by_name(task_name).update_attribute(:task_list, task_list)
end

Given /^the task called "([^\"]*)" belongs to the project called "([^\"]*)"$/ do |task_name, project_name|
  Given %(there is a task called "#{task_name}")
  Given %(there is a project called "#{project_name}")
  project = Project.find_by_name(project_name)
  Task.find_by_name(task_name).update_attribute(:project, project)
end

Given /^the task called "([^\"]*)" is due today$/ do |name|
  Given %(there is a task called "#{name}")
  Task.find_by_name(name).update_attribute(:due_on, Date.today)
end

Given /^the task called "([^\"]*)" is due tomorrow$/ do |name|
  Given %(there is a task called "#{name}")
  Task.find_by_name(name).update_attribute(:due_on, Date.today + 1)
end

Given /^the task called "([^\"]*)" is assigned to me$/ do |name|
  Given %(there is a task called "#{name}")
  task = Task.find_by_name(name)
  task.project.add_user(@current_user)
  task.assign_to(@user)
end

Given /^the task called "([^\"]*)" is assigned to "([^\"]*)"$/ do |task_name, login|
  Given %(there is a task called "#{task_name}")
  task = Task.find_by_name(task_name)
  user = User.find_by_login(login)
  task.project.add_user(user)
  task.assign_to(user)
end

Given /^I have no tasks assigned to me$/ do
  @current_user.assigned_tasks(:all).each { |task| task.destroy }
end

Given /^the task called "([^\"]*)" is (new|hold|open|resolved|rejected)$/ do |name, status|
  Task.find_by_name(name).update_attribute(:status, Task::STATUSES[status.to_sym])
end

Given /^the task called "([^\"]*)" is not archived$/ do |name|
  Task.find_by_name(name).update_attribute(:archived, false)
end

Given /^the task called "([^\"]*)" is archived$/ do |name|
  Task.find_by_name(name).update_attribute(:archived, true)
end

When /^the daily reminders for tasks are sent$/ do
  User.send_daily_task_reminders
end