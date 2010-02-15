Given /^today is "([^\"]*)"$/ do |date|
  Date.stub!(:today).and_return(Date.parse(date))
end