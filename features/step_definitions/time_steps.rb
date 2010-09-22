Given /^today is "([^\"]*)"$/ do |date|
  Date.stub!(:today).and_return(Date.parse(date))
end

Given /^today is ([a-z]+)$/i do |day|
  target_wday = %w[sun mon tue wed thu fri sat].index(day[0, 3].downcase)
  now = Time.now
  Time.stub!(:now).and_return(now.advance(:days => target_wday - now.wday))
end

Given /^the time is "([^\"]*)"$/ do |time|
  Time.stub!(:now).and_return(Time.parse(time))
end
