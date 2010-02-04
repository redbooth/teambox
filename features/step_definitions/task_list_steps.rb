Given /^there is a task list called "([^\"]*)"$/ do |name|
  TaskList.find_by_name(name) || Factory(:task_list, :name => name)
end

Given /^the task list called "([^\"]*)" belongs to the project called "([^\"]*)"$/ do |task_list_name, project_name|
  Given %(there is a task list called "#{task_list_name}")
  Given %(there is a project called "#{project_name}")
  project = Project.find_by_name(project_name)
  TaskList.find_by_name(task_list_name).update_attribute(:project, project)
end

When /^I follow "([^\"]*)" in the "([^\"]*)" task list panel$/ do |link_text, task_list_name|
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  When %(I follow "#{link_text}" within "#project_#{project.id}_task_list_#{task_list.id}_with_tasks")
end

Then /^I should see the task called "([^\"]*)" in the "([^\"]*)" task list panel$/ do |task_name, task_list_name|
  task = Task.find_by_name(task_name)
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  sleep(1)
  page.should have_xpath(%(//*[@id = "project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}_item"][not(contains(@style,'display: none'))]))
end

Then /^the task called "([^\"]*)" in the "([^\"]*)" task list panel should be hidden$/ do |task_name, task_list_name|
  task = Task.find_by_name(task_name)
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  sleep(1)
  page.should have_xpath(%(//*[@id = "project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}_item"][contains(@style,'display: none')]))
end

Then /^I should not see the task called "([^\"]*)" in the "([^\"]*)" task list panel$/ do |task_name, task_list_name|
  task = Task.find_by_name(task_name)
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  sleep(1)
  page.should_not have_css("#project_#{project.id}_task_list_#{task_list.id}_task_#{task.id}_item")
end

Then /^I should see the following tasks:$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |hash|
    Then %(I should see the task called "#{hash['task_name']}" in the "#{hash['task_list_name']}" task list panel)
  end
end

Then /^the following tasks should be hidden:$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |hash|
    Then %(the task called "#{hash['task_name']}" in the "#{hash['task_list_name']}" task list panel should be hidden)
  end
end

Then /^I should not see the following tasks:$/ do |table|
  # table is a Cucumber::Ast::Table
  table.hashes.each do |hash|
    Then %(I should not see the task called "#{hash['task_name']}" in the "#{hash['task_list_name']}" task list panel)
  end
end
