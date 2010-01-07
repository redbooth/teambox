Given /^I have a task list called "([^\"]*)"$/ do |name|
  @task_list = @current_project.create_task_list(@current_user,{:name => name})
end

Given /^I have a task called "([^\"]*)"$/ do |name|
  @task = @current_project.create_task(@current_user,@task_list,{:name => name})
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

Given /^I am the currently (.*)$/ do |user_type|
  @current_user ||= User.find_by_login(user_type) || Factory(user_type.to_sym) 
  @user = @current_user
end

Given /^I am logged in as (.*)$/ do |user_type|
  Given "I am the currently #{user_type}"
    And "I go to the login page"
    And "I fill in \"Email or Username\" with \"#{@current_user.email}\""
    And "I fill in \"Password\" with \"#{@current_user.password}\""
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

Given /I am the user (.*)$/ do |user_type|
  @user ||= Factory(user_type.to_sym)
end  

Then /^I should not see missing avatar image within "([^\"]*)"$/ do |selector|
  within(:css,selector) do
    page.should_not have_content("missing.jpg")
  end
end