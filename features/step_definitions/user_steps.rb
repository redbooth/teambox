Given /^I am currently "([^\"]*)"$/ do |login|
  @current_user = User.find_by_login(login) ||
                    (login == "mislav" ?
                      Factory(:mislav) : # Mislav has a first and last name, is not a generic user
                      Factory(:confirmed_user, :login => login, :email => "#{login}@example.com"))
end

Given /^(?:I am|I'm) logged in as @(\w+)$/ do |username|
  visit "/login/#{username}"
  @current_user = User.find_by_login(username)
end

Given /^(@\w+) exists?$/ do |username|
  each_user(username, true) {}
end

Given /^@(\w+) exists and is logged in$/ do |username|
  Given %(@#{username} exists)
    And %(I'm logged in as @#{username})
end

Given /^I am logged in as ([^@][^\"]*)$/ do |login|
  Given %(I am currently "#{login}")
    And %(I have confirmed my email)
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
  @current_user.update_attribute(:splash_screen,false)
end

Given /I have never confirmed my email/ do
  @current_user.update_attribute(:confirmed_user,false)
end

Given /^(?:My|His|Her) password is "([^\"]*)"$/ do |password|
  @current_user.update_attribute(:password, password)
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

Given /^(@.+) (?:has|have) (?:his|her|their) locale set to (.+)$/ do |users, name|
  locale = case name.downcase
  when "english" then "en"
  when "spanish" then "es"
  when "italian" then "it"
  when "french"  then "fr"
  when "catalan" then "ca"
  else
    raise ArgumentError, "don't know locale #{name}"
  end

  each_user(users) do |user|
    user.update_attribute :locale, locale
  end
end

Given /^(@.+) (?:has|have) (?:his|her|their) time zone set to (.+)$/ do |users, zone|
  each_user(users) do |user|
    user.update_attribute :time_zone, zone
  end
end

Given /I am the user (.*)$/ do |login|
  @current_user ||= Factory(login.to_sym)
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

Given /^I set my preference to collapsed threads$/ do
  visit collapse_activities_path 
  @current_user.reload.settings["collapse_activities"].should be_true
end

Given /^I set my preference to expanded threads$/ do
  visit expand_activities_path 
  @current_user.reload.settings["collapse_activities"].should be_false
end
