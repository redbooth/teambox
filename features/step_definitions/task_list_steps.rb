Given /^I have a task list called "([^\"]*)"$/ do |name|
  @task_list = (@current_project || Factory(:project)).create_task_list(@current_user,{:name => name})
end

Given /^there is a task list called "([^\"]*)"$/ do |name|
  TaskList.find_by_name(name) || Factory(:task_list, :name => name)
end

Given /^the following task lists? with associations exists?:?$/ do |table|
  table.hashes.each do |hash|
    Factory(:task_list,
      :name => hash[:name],
      :project => Project.find_by_name(hash[:project])
    )
  end
end

Given /^the task list called "([^\"]*)" belongs to the project called "([^\"]*)"$/ do |task_list_name, project_name|
  Given %(there is a task list called "#{task_list_name}")
  Given %(there is a project called "#{project_name}")
  project = Project.find_by_name(project_name)
  TaskList.find_by_name(task_list_name).update_attribute(:project, project)
end

When /^I follow "([^\"]*)" in the "([^\"]*)" task list$/ do |link_text, task_list_name|
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  When %(I follow "#{link_text}" within "#project_#{project.id}_task_list_#{task_list.id}_with_main_tasks")
end

Then /^I should not see a "([^\"]*)" link in the "([^\"]*)" task list$/ do |link_text, task_list_name|
  task_list = TaskList.find_by_name(task_list_name)
  project = task_list.project
  page.should_not have_xpath(%(//*[@id = "project_#{project.id}_task_list_#{task_list.id}_with_main_tasks"]//a[text()="#{link_text}"]))
end

When /^I fill in "([^\"]*)" with "([^\"]*)" in the new task form of the "([^\"]*)" task list$/ do |field, value, task_list_name|
  task_list = TaskList.find_by_name(task_list_name)
  within(:css, "#project_#{task_list.project.id}_task_list_#{task_list.id} form") do
    fill_in(field, :with => value)
  end
end

Then /^(?:|I )should see "([^\"]*)" as a task in the task list$/ do |text|
  Then %(I should see '#{text}' within '.tasks')
end

Then /^(?:|I )should see "([^\"]*)" as a task name$/ do |text|
  Then %(I should see '#{text}' within '.tasks a.name')
end

Then /^I should see the task list "([^\"]*)" before "([^\"]*)"$/ do |task_list1, task_list2|
  TaskList.find_by_name(task_list1).position.should < TaskList.find_by_name(task_list2).position
end
