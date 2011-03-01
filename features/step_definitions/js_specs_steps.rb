When /^I run the (.+?) javascript specs$/ do |suite|
  visit "/js_specs/#{suite}" 
end

Then /^I should see all specs passing$/ do
  Then %(I should see "Test passed")
  Then %(I should not see "FAILED")
end
