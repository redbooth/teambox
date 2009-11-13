Given /^I am logged in as (.*)$/ do |user_type|
  @current_user ||= User.find_by_login(user_type) || Factory(user_type.to_sym) 
  @user = @current_user

  visit(login_path)
  fill_in("login",    :with => @current_user.email)
  fill_in("password", :with => @current_user.password)
  click_button("Login")
end

Given /^I login as (.*)$/ do |user_type|
  @current_user ||= User.find_by_login(user_type) || Factory(user_type.to_sym) 
  @user = @current_user

  visit(login_path)
  fill_in("login",    :with => @current_user.email)
  fill_in("password", :with => @current_user.password)
  click_button("Login")
end

Given /I have confirmed my email/ do
  @current_user.update_attribute(:confirmed_user,true)
end

Given /I have never confirmed my email/ do
  @current_user.update_attribute(:confirmed_user,false)
end

Given /It's my first time logging in/ do
  @current_user.update_attribute(:welcome,false)
end

Given /I am currently in the project (.*)$/ do |project_type|
  @current_project ||= Factory(project_type.to_sym)
  visit(projects_path(@current_project))
end    

Given /I am the user (.*)$/ do |user_type|
  @user ||= Factory(user_type.to_sym)
end  