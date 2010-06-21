#TODO: I think this should go once we have the CI server is set up,
# it is more straightforward to pass the login
# when creating users (see Given I am "..." step) than to create a factory
# for each username, in my opinion.
Given /^I am currently "([^\"]*)"$/ do |login|
  @current_user ||= User.find_by_login(login) || Factory(login.to_sym)
  @user = @current_user
end

#TODO: I think this should go once we have the CI server is set up,
# it is more straightforward to pass the login
# when creating users (see Given I am "..." step) than to create a factory
# for each username, in my opinion.
Given /^I am logged in as ([^\"]*)$/ do |login|
  Given %(I am currently "#{login}")
    And "I go to the login page"
    And "I fill in \"Email or Username\" with \"#{@current_user.email}\""
    And "I fill in \"Password\" with \"#{@current_user.password}\""
    And "I press \"Login\""
end

Given /^I am "([^\"]*)"$/ do |login|
  @current_user = User.find_by_login(login) || Factory(:user, :login => login, :email => "#{login}@example.com")
  @user = @current_user
end

Given /^I am logged in as "([^\"]*)"$/ do |login|
  Given %(I am "#{login}")
  Given %(I have confirmed my email)
    And "I go to the login page"
    And "I fill in \"Email or Username\" with \"#{login}\""
    And "I fill in \"Password\" with \"dragons\""
    And "I press \"Login\""
end


Given /^I log out$/ do
  visit(logout_path)
end

Given /I have confirmed my email/ do
  @current_user.update_attribute(:confirmed_user,true)
end

Given /I have never confirmed my email/ do
  @current_user.update_attribute(:confirmed_user,false)
end

Given /It is my first time logging in/ do
  @current_user.update_attribute(:welcome,false)
end

Given /I am currently in the project (.*)$/ do |project_type|
  @current_project ||= Factory(project_type.to_sym)
  visit(projects_path(@current_project))
end

Given /I am in the project called "([^\"]*)"$/ do |name|
  Given %(there is a project called "#{name}")
  project = Project.find_by_name(name)
  project.add_user(@current_user)
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

Given /^"([^\"]*)" is watching the conversation "([^\"]*)"$/ do |username,name|
  conversation = Conversation.find_by_name(name)
  conversation.add_watcher User.find_by_login(username)
end

Then /^"([^\"]*)" should be watching the conversation "([^\"]*)"$/ do |username,name|
  conversation = Conversation.find_by_name(name)
  conversation.watching?(User.find_by_login(username))
end

Given /^"([^\"]*)" stops watching the conversation "([^\"]*)"$/ do |username,name|
  conversation = Conversation.find_by_name(name)
  conversation.remove_watcher User.find_by_login(username)
end

Then /^"([^\"]*)" should not be watching the conversation "([^\"]*)"$/ do |username,name|
  conversation = Conversation.find_by_name(name)
  !conversation.watching?(User.find_by_login(username))
end

Given /^all the users are in the project with name: "([^\"]*)"$/ do |name|
  Given %(there is a project called "#{name}")
  project = Project.find_by_name(name)
  User.all.each { |user| project.add_user(user) }
end

Given /^there is a user called "([^\"]*)"$/ do |login|
  Factory(:user, :login => login, :email => "#{login}@example.com")
end

Given /^the user called "([^\"]*)" is confirmed$/ do |login|
  User.find_by_login(login).update_attribute(:confirmed_user, true)
end

Then /^the user called "([^\"]*)" should administrate the project called "([^\"]*)"/ do |login,name|
  Given %(there is a project called "#{name}")
  project = Project.find_by_name(name)
  project.admin?(User.find_by_login(login))
end

Then /^the user called "([^\"]*)" should not administrate the project called "([^\"]*)"/ do |login,name|
  Given %(there is a project called "#{name}")
  project = Project.find_by_name(name)
  !project.admin?(User.find_by_login(login))
end

Given /^the user with login: "([^\"]*)" is deleted$/ do |login|
  user = User.find_by_login(login)
  user.destroy unless user.nil?
end

Given /I am the user (.*)$/ do |login|
  @user ||= Factory(login.to_sym)
end

Then /^I should not see missing avatar image within "([^\"]*)"$/ do |selector|
  within(:css,selector) do
    page.should_not have_content("missing.jpg")
  end
end

Given /^I have the daily task reminders turned on$/ do
  @current_user.update_attribute(:wants_task_reminder, true)
end

Given /^I have the daily task reminders turned off$/ do
  @current_user.update_attribute(:wants_task_reminder, false)
end
