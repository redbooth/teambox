Then /^I should see the project "([^\"]*)"$/ do |project_name|
  Then %(I should see "#{project_name}" within "#my_projects")
end

Then /^I should see the task "([^\"]*)" in the sidebar$/ do |task_name|
  Then %(I should see "#{task_name}" within "#my_tasks")
end

Then /^I should see the organization "([^\"]*)" in the sidebar$/ do |organization_name|
  Then %(I should see "#{organization_name}" within "#my_organizations")
end

When /^I follow "([^\"]*)" in the sidebar$/ do |link|
  When %(I follow "#{link}" within "#column")
end

Then /^I should see the recent activity link for the "([^\"]*)" project within the sidebar$/ do |project_name|
  project = Project.find_by_name(project_name)
  path = project_path(project)
  Then %(I should see "Recent activity" within "#column a.recent_activity[href='#{path}']")
end

Then /^I should see the tasks link for the "([^\"]*)" project within the sidebar$/ do |project_name|
  project = Project.find_by_name(project_name)
  path = project_task_lists_path(project)
  Then %(I should see "Tasks" within "#column a.tasks[href='#{path}']")
end

Then /^I should see the conversations link for the "([^\"]*)" project within the sidebar$/ do |project_name|
  project = Project.find_by_name(project_name)
  path = project_conversations_path(project)
  Then %(I should see "Conversations" within "#column a.conversations[href='#{path}']")
end

Then /^I should see the pages link for the "([^\"]*)" project within the sidebar$/ do |project_name|
  project = Project.find_by_name(project_name)
  path = project_pages_path(project)
  Then %(I should see "Pages" within "#column a.pages[href='#{path}']")
end

Then /^I should see the files link for the "([^\"]*)" project within the sidebar$/ do |project_name|
  project = Project.find_by_name(project_name)
  path = project_uploads_path(project)
  Then %(I should see "Files" within "#column a.files[href='#{path}']")
end

Then /^I should not see the people link for the "([^\"]*)" project within the sidebar$/ do |project_name|
  project = Project.find_by_name(project_name)
  path = project_people_path(project)
  Then %(I should not see "People & permissions" within "#column")
end

Then /^I should not see the configuration link for the "([^\"]*)" project within the sidebar$/ do |project_name|
  project = Project.find_by_name(project_name)
  path = project_settings_path(project)
  Then %(I should not see "Configuration" within "#column")
end
