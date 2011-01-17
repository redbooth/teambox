When /^I run the (.+?) specs$/ do |suite|
  visit "/js_specs/#{suite}" 
end

Then /^I should see all specs passing$/ do
  Then %(I should not see "FAILED")
end
