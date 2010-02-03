Given /^there is a task list called "([^\"]*)"$/ do |name|
  TaskList.find_by_name(name) || Factory(:task_list, :name => name)
end

Given /^the task list called "([^\"]*)" belongs to the project called "([^\"]*)"$/ do |task_list_name, project_name|
  Given %(there is a task list called "#{task_list_name}")
  Given %(there is a project called "#{project_name}")
  project = Project.find_by_name(project_name)
  TaskList.find_by_name(task_list_name).update_attribute(:project, project)
end

Then /^I should see the task called "([^\"]*)" in the "([^\"]*)" task list panel$/ do |task_name, task_list_name|
  task = Task.find_by_name(task_name)
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  page.should have_css("#project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}_item")
end

Then /^the task called "([^\"]*)" in the "([^\"]*)" task list panel should be hidden$/ do |task_name, task_list_name|
  task = Task.find_by_name(task_name)
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  page.should have_xpath(%(//*[@id = "project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}_item"][contains(@style,'display: none')]))
end

Then /^I should not see the task called "([^\"]*)" in the "([^\"]*)" task list panel$/ do |task_name, task_list_name|
  task = Task.find_by_name(task_name)
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  page.should_not have_css("#project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}_item")
end