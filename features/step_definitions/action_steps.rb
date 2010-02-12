When /^I wait for ([\d\.]+) seconds?$/ do |secs|
  sleep(secs.to_f)
end