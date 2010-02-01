Then /^I should see an error message: "([^\"]*)"$/ do |text|
  Then %(I should see "#{text}" within ".flash_error")
end
