Given /^there is a task called "([^\"]*)"$/ do |name|
  Task.find_by_name(name) || Factory(:task, :name => name)
end

Given /^I have a task called "([^\"]*)"$/ do |name|
  task_list = @task_list || Factory(:task_list)
  project = @current_project || Factory(:project)
  @task = project.create_task(@current_user, task_list, {:name => name})
end

## FIXME: it's better for 'givens' to set tasks up directly in the db:

Given /^I have a task on open$/ do
  And 'I select "Mislav Marohnić" from "comment_target_attributes_assigned_id"'
  And 'I press "Save"'
  And 'I wait for 0.3 seconds'
end

Given /^I have a task on hold$/ do
  And 'I click the element "status_hold"'
  And 'I press "Save"'
  And 'I wait for 0.3 seconds'
end

Given /^I have a task on resolved$/ do
  And 'I click the element "status_resolved"'
  And 'I press "Save"'
  And 'I wait for 0.3 seconds'
end

Given /^I have a task on rejected$/ do
  And 'I click the element "status_rejected"'
  And 'I press "Save"'
  And 'I wait for 0.3 seconds'
end

Given /^the following tasks? with associations exists?:?$/ do |table|
  table.hashes.each do |hash|
    Factory(:task,
      :name => hash[:name],
      :task_list => TaskList.find_by_name(hash[:task_list]),
      :project => Project.find_by_name(hash[:project])
    )
  end
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

Given /^the task called "([^\"]*)" was due (\d+) days ago$/ do |name, days_ago|
  Given %(there is a task called "#{name}")
  Task.find_by_name(name).update_attribute(:due_on, Date.today - days_ago.to_i)
end

Given /^the task called "([^\"]*)" is due tomorrow$/ do |name|
  Given %(there is a task called "#{name}")
  Task.find_by_name(name).update_attribute(:due_on, Date.today + 1)
end

Given /^the task called "([^\"]*)" is due in (\d+) days?$/ do |name, in_days|
  Given %(there is a task called "#{name}")
  Task.find_by_name(name).update_attribute(:due_on, Date.today + in_days.to_i)
end

Given /^the task called "([^\"]*)" does not have a due date$/ do |name|
  Given %(there is a task called "#{name}")
  Task.find_by_name(name).update_attribute(:due_on, nil)
end

Given /^the task called "([^\"]*)" is assigned to me$/ do |name|
  Given %(there is a task called "#{name}")
  task = Task.find_by_name(name)
  task.project.add_user(@current_user)
  task.assign_to(@current_user)
end

Given /^the task called "([^\"]*)" is assigned to "([^\"]*)"$/ do |task_name, login|
  Given %(there is a task called "#{task_name}")
  task = Task.find_by_name(task_name)
  user = User.find_by_login(login)
  task.project.add_user(user)
  task.assign_to(user)
end

Given /^I have no tasks assigned to me$/ do
  @current_user.assigned_tasks.destroy_all
end

Given /^the task called "([^\"]*)" is (new|hold|open|resolved|rejected)$/ do |name, status|
  Task.find_by_name(name).update_attribute(:status, Task::STATUSES[status.to_sym])
end

Then /^I should( not)? see the task called "([^\"]*)" in the "([^\"]*)" task list$/ do |negative, task_name, task_list_name|
  task_list = TaskList.find_by_name!(task_list_name)
  project = task_list.project
  Then %(I should#{negative} see "#{task_name}" within "#project_#{project.id}_task_list_#{task_list.id}")
end

Then /^I should see the following tasks:$/ do |table|
  table.hashes.each do |hash|
    Then %(I should see the task called "#{hash['task_name']}" in the "#{hash['task_list_name']}" task list)
  end
end

Then /^I should not see the following tasks:$/ do |table|
  table.hashes.each do |hash|
    Then %(I should not see the task called "#{hash['task_name']}" in the "#{hash['task_list_name']}" task list)
  end
end

# needed to change the task's status
When /^I click the element "([^\"]*)"$/ do |id|
  find(%(##{id})).click
end
