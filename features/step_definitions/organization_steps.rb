Given /I am an administrator in the organization called "([^\"]*)"$/ do |name|
  organization = Organization.find_by_name(name) || Organization.create!(:name => name, :permalink => name)
  organization.add_member(@current_user, :admin)
end

Given /I am a participant in the organization called "([^\"]*)"$/ do |name|
  organization = Organization.find_by_name(name) || Organization.create!(:name => name, :permalink => name)
  organization.add_member(@current_user, :participant)
end

Given /"([^\"]*)" is an administrator in the organization called "([^\"]*)"$/ do |user,name|
  user = User.find_by_login(user)
  organization = Organization.find_by_name(name) || Organization.create!(:name => name, :permalink => name)
  organization.add_member(user, :admin)
end

Given /"([^\"]*)" is a participant in the organization called "([^\"]*)"$/ do |user,name|
  user = User.find_by_login(user)
  organization = Organization.find_by_name(name) || Organization.create!(:name => name, :permalink => name)
  organization.add_member(user, :participant)
end

Given /the project "([^\"]*)" belongs to "([^\"]*)" organization$/ do |project,organization|
  project = Project.find_by_name(project)
  organization = Organization.find_by_name(organization)
  project.organization = organization
  project.save!
end

