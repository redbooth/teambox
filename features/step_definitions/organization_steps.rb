Given /^I am using the community version$/ do
  Teambox.config.community = true
end

Given /I am an administrator in the organization called "([^\"]*)"$/ do |name|
  organization = Organization.find_by_name(name) || Organization.create!(:name => name, :permalink => name)
  organization.add_member(@current_user, :admin)
end

Given /I am an administrator in the organization of the project called "([^\"]*)"$/ do |name|
  project = Project.find_by_name(name)
  project.organization.add_member(@current_user, :admin)
end

Given /"([^\"]*)" is an administrator in the organization of the project called "([^\"]*)"$/ do |username,name|
  project = Project.find_by_name(name)
  project.organization.add_member(User.find_by_login(username), :admin)
end


Given /the organization of the project called "([^\"]*)" is called "([^\"]*)"$/ do |project_name, name|
  project = Project.find_by_name(project_name)
  project.organization.update_attribute(:name, name)
end

Given /I am a participant in the organization called "([^\"]*)"$/ do |name|
  organization = Organization.find_by_name(name) || Organization.create!(:name => name, :permalink => name)
  organization.add_member(@current_user, :participant)
end

Given /I am a participant in the organization of the project called "([^\"]*)"$/ do |name|
  project = Project.find_by_name(name)
  project.organization.add_member(@current_user, :participant)
end

Given /"([^\"]*)" is an administrator in the organization called "([^\"]*)"$/ do |user,name|
  user = User.find_by_login(user)
  organization = Organization.find_by_name(name) || Organization.create!(:name => name, :permalink => name)
  organization.add_member(user, :admin)
end

Given /"([^\"]*)" is not a member of the organization called "([^\"]*)"$/ do |user,name|
  user = User.find_by_login(user)
  organization = Organization.find_by_name(name)
  membership = organization.memberships.find_by_user_id(user.id)
  membership.destroy if membership
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

Given /^the organization called "([^\"]*)" has no projects?$/ do |organization|
  Organization.find_by_name(organization).projects.destroy_all
end

Then /"([^\"]*)" should belong to the organization "([^\"]*)" as (?:a|an) ([a-zA-Z]+)$/ do |login, organization,role|
  user = User.find_by_login(login)
  organization = Organization.find_by_name(organization)
  organization.memberships.find_by_user_id(user.id).role.should == Membership::ROLES[role.to_sym]
end

Then /"([^\"]*)" should not belong to the organization "([^\"]*)"$/ do |login, organization|
  user = User.find_by_login(login)
  organization = Organization.find_by_name(organization)
  organization.memberships.find_by_user_id(user.id).should be_nil
end

Then /^I fill in the organization description with "([^"]*)"$/ do |text|
  Then %(I fill in "organization_description" with "#{text}")
end

Then /I should see "([^"]*)" within custom html/ do |text|
  Then %(I should see "#{text}" within ".custom_html")
end
