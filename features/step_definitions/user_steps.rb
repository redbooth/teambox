Given /^I am logged in as a (.*)$/ do |user_type|
  @current_user ||= Factory(user_type.to_sym)
  @user = @current_user
  visit(login_path)
  fill_in("login",    :with => @current_user.login)
  fill_in("password", :with => @current_user.password)
  click_button("Login")
end

Given /^I login as a (.*)$/ do |user_type|
  @current_user ||= Factory(user_type.to_sym)
  @user = @current_user
  fill_in("login",    :with => @current_user.login)
  fill_in("password", :with => @current_user.password)
  click_button("Login")
end
