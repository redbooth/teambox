Given /^the project page "([^\"]*)" exists in "([^\"]*)"$/ do |name, project_name|
  project = Project.find_by_name(project_name)
  @page = project.new_page(@current_user, {:name => name})
  @page.save
end

Given /^I created? (\d+) pages? in the "([^\"]*)" project/ do |n,project_name|
  project = Project.find_by_name(project_name)
  n.to_i.times { project.new_page(@current_user, :name => "Some page for the #{project_name} project").save! }
end

