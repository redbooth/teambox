Given /^I am using the community version$/ do
  Teambox.config.community = true
end

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

Given /^the database is empty$/ do
  User.destroy_all
  Organization.destroy_all
end

Then /"([^\"]*)" should belong to the organization "([^\"]*)" as (?:a|an) ([^\"]*)$/ do |login, organization,role|
  user = User.find_by_login(login)
  organization = Organization.find_by_name(organization)
  organization.memberships.find_by_user_id(user.id).role.should == Membership::ROLES[role.to_sym]
end

Then /"([^\"]*)" should not belong to the organization "([^\"]*)"$/ do |login, organization|
  user = User.find_by_login(login)
  organization = Organization.find_by_name(organization)
  organization.memberships.find_by_user_id(user.id).should be_nil
end

Then /"([^\"]*)" should be an external user in the organization "([^\"]*)"$/ do |login, organization|
  user = User.find_by_login(login)
  organization = Organization.find_by_name(organization)
  organization.memberships.find_by_user_id(user.id).role.should == 10
end
