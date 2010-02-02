Given /^the user with login: "([^\"]*)" has asked to reset his password$/ do |login|
  @reset_password = Factory(:reset_password, :user => User.find_by_login(login))
end

When /^I follow the reset password link$/ do
  visit reset_password_path(@reset_password.reset_code)
end