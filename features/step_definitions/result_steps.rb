Then /^I should see an error message$/ do
  Then %(I should see .+ within ".flash_error")
end

Then /^I should see an error message: "([^\"]*)"$/ do |text|
  Then %(I should see "#{text}" within ".flash_error")
end
