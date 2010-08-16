When /^I should see an error message: "([^\"]*)"$/ do |text|
  Then %(I should see "#{text}" within ".flash-error")
end

When /^"([^\"]*)" accepts the invitation from "([^\"]*)"$/ do |username,email|
  Then %(I log out)
  Then %(I am logged in as "#{username}")
  open_email(email)
  Then %(I follow "Accept the invitation to start collaborating" in the email)
  Then %(I press "Accept")
end
