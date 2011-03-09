Then /^(?:|I )should see "([^\"]*)" as the template name$/ do |text|
  Then %(I should see '#{text}' within '.task_list_templates .name')
end

Then /^(?:|I )should see "([^\"]*)" as a template task name$/ do |text|
  Then %(I should see '#{text}' within '.task_list_templates .title')
end

Then /^(?:|I )should see "([^\"]*)" as a template task description/ do |text|
  Then %(I should see '#{text}' within '.task_list_templates .desc')
end

Given /^(?:|I )have a task list template called "([^\"]*)"$/ do |name|
  project = @current_project || Factory(:project)
  task_list_template = Factory(:complete_task_list_template, :organization => project.organization, :name => name)
end

