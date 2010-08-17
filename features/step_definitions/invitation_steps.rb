When /^"([^\"]*)" accepts the invitation from "([^\"]*)"$/ do |username,email|
  Then %(I log out)
  Then %(I am logged in as "#{username}")
  open_email(email)
  Then %(I follow "Accept the invitation to start collaborating" in the email)
  Then %(I press "Accept")
end
