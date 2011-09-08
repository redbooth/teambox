Given /^there is a project called "([^\"]*)"$/ do |name|
  Project.find_by_name(name) || Factory(:project, :name => name)
end

Given /^"([^\"]*)" sent an invitation to "([^\"]*)" for the project "([^\"]*)"$/ do |login, email, project_name|
  user = User.find_by_login(login)
  project = Project.find_by_name(project_name)
  Factory(:invitation, :user => user, :email => email, :project => project)
end

Given /^the first admin in the project "([^\"]*)" sent an invitation to "([^\"]*)"$/ do |project_name, login|
  user = User.find_by_login(login)
  project = Project.find_by_name(project_name)
  invite = Invitation.new(:user_or_email => user.login)
  invite.project = project
  invite.user = project.admins.first
  invite.save!
end

Then /"([^\"]*)" should belong to the project "([^\"]*)" as (?:a|an) ([^\"]*)$/ do |login, project, role|
  user = User.find_by_login(login)
  project = Project.find_by_name(project)
  project.people.find_by_user_id(user.id).role.should == Person::ROLES[role.to_sym]
end

# "Given a project with users @john and @richard"
Given(/^a project with users? (.+)$/) do |users|
  @current_project = Factory(:project)
  
  each_user(users, true) do |user|
    person = Factory(:person, :user => user, :project => @current_project)
    person.user.update_attribute :splash_screen, false
  end
end

Given(/^(@.+) left the project$/) do |users|
  each_user(users) do |user|
    @current_project.remove_user user
  end
end

Given(/^Only (@.+) is in the project$/) do |users|
  user_list = []
  project_users = @current_project.users
  each_user(users) {|user| user_list << user}
  users_to_remove = project_users - user_list
  users_to_remove.each {|user| @current_project.remove_user user}
end

Given /I am currently in the project (.*)$/ do |project_type|
  @current_project ||= Factory(project_type.to_sym)
  visit(projects_path(@current_project))
end

Given /(@.+) is currently in the project (.*)$/ do |usernames, project_type|
  @current_project ||= Factory(project_type.to_sym)
  usernames.scan(/(?:^|\W)@(\w+)/).flatten.each do |name|
    @current_project.add_user User.find_by_login(name)
  end
end

Given /I have recently managed the project "([^\"]*)"$/ do |name|
  @current_project ||= Project.find_by_name(name)
end

Given /I am in the project called "([^\"]*)"$/ do |name|
  Given %(there is a project called "#{name}")
  @current_project = Project.find_by_name(name)
  @current_project.add_user(@current_user)
end

Given /I am a commenter in the project called "([^\"]*)"$/ do |name|
  Given %(there is a project called "#{name}")
  project = Project.find_by_name(name)
  project.remove_user(@current_user)
  project.add_user(@current_user, :role => Person::ROLES[:commenter])
end

Given /^"([^\"]*)" is an administrator in the project(?: called "([^\"]*)")?$/ do |user, name|
  Given %(there is a project called "#{name}") unless name.nil?
  project = name ? Project.find_by_name(name) : @current_project
  user = User.find_by_login(user)
  project.remove_user(user)
  project.add_user(user, :role => Person::ROLES[:admin])
end

Given /^"([^\"]*)" is in the project called "([^\"]*)"$/ do |username,name|
  Given %(there is a project called "#{name}")
  project = Project.find_by_name(name)
  project.add_user User.find_by_login(username)
end

Given /^"([^\"]*)" is not in the project called "([^\"]*)"$/ do |username,name|
  Given %(there is a project called "#{name}")
  project = Project.find_by_name(name)
  project.remove_user User.find_by_login(username)
end

Given /^all the users are in the project with name: "([^\"]*)"$/ do |name|
  Given %(there is a project called "#{name}")
  project = Project.find_by_name(name)
  User.all.each { |user| project.add_user(user) }
end

Then /^(?:|I )should see the unconfirmed email message$/ do
  text = "An email was sent to this user, but they still haven't confirmed"

  if Capybara.current_driver == Capybara.javascript_driver
    assert page.has_xpath?(XPath::HTML.content(text), :visible => true)
  elsif page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then /^(?:|I )should see the unauthorized private project message/ do
  text = "This is a private project and you're not authorized to access it."

  if Capybara.current_driver == Capybara.javascript_driver
    assert page.has_xpath?(XPath::HTML.content(text), :visible => true)
  elsif page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Given /^we are navigating the "([^\"]*)" project$/ do |project_name|
  @current_project = Project.find_by_name(project_name)
end

Given /^there is a project with a conversation$/ do
  @current_project = @current_user.projects.first || Factory(:project)
  Factory(:conversation,
          :user => @current_user, 
          :project => @current_project,
          :name => "Conversation title",
          :body => "Conversation body")
end
