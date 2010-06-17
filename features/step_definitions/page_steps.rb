Given /^the project page "([^\"]*)" exists in "([^\"]*)"$/ do |name, project_name|
  project = Project.find_by_name(project_name)
  @page = project.new_page(@current_user, {:name => name})
  @page.save
end