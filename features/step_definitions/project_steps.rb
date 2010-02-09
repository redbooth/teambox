Given /^there is a project called "([^\"]*)"$/ do |name|
  Project.find_by_name(name) || Factory(:project, :name => name)
end

Given /^"([^\"]*)" is the owner of the project "([^\"]*)"/ do |login, project_name|
  user = User.find_by_login(login)
  project = Project.find_by_name(project_name)
  project.add_user(user)
  project.update_attribute(:user, user)
end

Given /^"([^\"]*)" sent an invitation to "([^\"]*)" for the project "([^\"]*)"$/ do |login, email, project_name|
  user = User.find_by_login(login)
  project = Project.find_by_name(project_name)
  Factory(:invitation, :user => user, :email => email, :project => project)
end