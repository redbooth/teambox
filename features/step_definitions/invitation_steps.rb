When /^"([^\"]*)" accepts the invitation from "([^\"]*)"$/ do |username,email|
  Then %(I log out)
  Then %(I am logged in as #{username})
  open_email(email)
  Then %(I follow "Accept the invitation to start collaborating" in the email)
  Then %(I press "Accept")
end

When /^(?:|I )fill in the invite by email box with "([^\"]*)"(?: within "([^\"]*)")?$/ do |value, selector|
  with_scope(selector) do
    find(:xpath, '//textarea[contains(@name, \'[invite_emails]\')]').set(value)
  end
end


