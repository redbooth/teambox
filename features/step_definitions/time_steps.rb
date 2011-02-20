require 'timecop'

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

Given /^utc time is now (\d+) hours? and a bit before midnight$/ do |hours|
  time_in_future = ((Date.today + 1).to_time_in_current_zone - (60 * 60 * hours.to_i)) + 60
  Timecop.travel(time_in_future)
end

Then /^time is flowing normally again$/ do
  Timecop.return
end

