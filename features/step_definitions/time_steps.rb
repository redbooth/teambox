Given /^today is "([^\"]*)"$/ do |date|
  Date.stub!(:today).and_return(Date.parse(date))
end

Given /^we are in the "([^\"]*)" time zone$/ do |zone|
  Rails.configuration.time_zone = zone
end