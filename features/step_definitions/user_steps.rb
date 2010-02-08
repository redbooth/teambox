Given /^I have a task list called "([^\"]*)"$/ do |name|
  @task_list = (@current_project || Factory(:project)).create_task_list(@current_user,{:name => name})
end

Given /^I have a task called "([^\"]*)"$/ do |name|
  task_list = @task_list || Factory(:task_list)
  project = @current_project || Factory(:project)
  @task = project.create_task(@current_user, task_list, {:name => name})
end

Given /^I have a task on open$/ do
  When  "I fill in \"comment_body\" with \"I fused the dino eggs to the engine\""
  And  "I select \"Mislav Marohnić\" from \"comment_target_attributes_assigned_id\""
  And  "I press \"Comment\""
  Then "I should see \"new\" within \".task_status_new\""
  And  "I should see \"→\" within \".comment .status_arr\""
  And  "I should see \"M. Marohnić\" within \".task_status_open\""
  And  "I should see \"I fused the dino eggs to the engine\" within \".body\""
  And  "I should see \"open\" within \".task_header h2\""
  And  "I should see \"Mislav Marohnić\" within \".assignment\""
  And  "I should see \"1\" within \".active_open\""
end

Given /^I have a task on hold$/ do
  When "I fill in \"comment_body\" with \"I need to wait till the engine cools down\""
   And "I click the element \"status_hold\""
   And "I press \"Comment\""
  Then "I should see \"new\" within \".task_status_new\""
   And "I should see \"→\" within \".comment .status_arr\""
   And "I should see \"hold\" within \".task_status_hold\""
   And "I should see \"I need to wait till the engine cools down\" within \".body\""
   And "I should see \"hold\" within \".task_header h2\""
   And "I should see \"1\" within \".active_hold\""
end


Given /^I have a task on resolved$/ do
  When "I fill in \"comment_body\" with \"I need to wait till the engine cools down\""
   And "I click the element \"status_resolved\""
   And "I press \"Comment\""
  Then "I should see \"new\" within \".task_status_new\""
   And "I should see \"→\" within \".comment .status_arr\""
   And "I should see \"resolved\" within \".task_status_resolved\""
   And "I should see \"I need to wait till the engine cools down\" within \".body\""
   And "I should see \"resolved\" within \".task_header h2\""
   And "I should see \"1\" within \".active_resolved\""
end

Given /^I have a task on rejected$/ do
  When "I fill in \"comment_body\" with \"I need to wait till the engine cools down\""
   And "I click the element \"status_rejected\""
   And "I press \"Comment\""
  Then "I should see \"new\" within \".task_status_new\""
   And "I should see \"→\" within \".comment .status_arr\""
   And "I should see \"rejected\" within \".task_status_rejected\""
   And "I should see \"I need to wait till the engine cools down\" within \".body\""
   And "I should see \"rejected\" within \".task_header h2\""
   And "I should see \"1\" within \".active_rejected\""
end

Then /^I should see for task status tag with (.*) and (.*)$/ do |current_status,status|

  current_status_text = current_status == "open" ? "M. Marohnić" : current_status
  status_text = status == "open" ? "M. Marohnić" : status

  unless current_status == status
    Then "I should see \"#{current_status_text}\" within \".task_status_#{current_status}\""
    And "I should see \"→\" within \".comment .status_arr\""
  end
  Then "I should see \"#{status_text}\" within \".task_status_#{status}\""
end

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
  @current_user ||= User.find_by_login(login) || Factory(:user, :login => login, :email => "#{login}@example.com")
  @user = @current_user
end

Given /^I am logged in as "([^\"]*)"$/ do |login|
  Given %(I am "#{login}")
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
