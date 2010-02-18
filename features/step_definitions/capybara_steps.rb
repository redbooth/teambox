require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^I go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^I press "([^\"]*)"$/ do |button|
  click_button(button)
end

When /^I press "([^\"]*)" within "([^\"]*)"$/ do |button,selector|
  within(:css,selector) do
    click_button(button)
  end
end

When /^I click the element "([^\"]*)"$/ do |element|
  find(%(//*[@id="#{element}"])).click
end

When /^I follow "([^\"]*)"$/ do |link|
  click_link(link)
end

When /^I follow "([^\"]*)" within "([^\"]*)"$/ do |link, selector|
  within(:css, selector) do
    click_link(link)
  end
end

When /^I fill in "([^\"]*)" with "([^\"]*)"$/ do |field, value|
  fill_in(field, :with => value)
end

When /^I fill in "([^\"]*)" for "([^\"]*)"$/ do |value, field|
  fill_in(field, :with => value)
end

# Use this to fill in an entire form with data from a table. Example:
#
#   When I fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
When /^I fill in the following:$/ do |fields|
  fields.rows_hash.each do |name, value|
    When %{I fill in "#{name}" with "#{value}"}
  end
end

When /^I select "([^\"]*)" from "([^\"]*)"$/ do |value, field|
  select(value, :from => field)
end

# Use this step in conjunction with Rail's datetime_select helper. For example:
# When I select "December 25, 2008 10:00" as the date and time
When /^I select "([^\"]*)" as the date and time$/ do |time|
  select_datetime(time)
end

# Use this step when using multiple datetime_select helpers on a page or
# you want to specify which datetime to select. Given the following view:
#   <%= f.label :preferred %><br />
#   <%= f.datetime_select :preferred %>
#   <%= f.label :alternative %><br />
#   <%= f.datetime_select :alternative %>
# The following steps would fill out the form:
# When I select "November 23, 2004 11:20" as the "Preferred" date and time
# And I select "November 25, 2004 10:30" as the "Alternative" date and time
When /^I select "([^\"]*)" as the "([^\"]*)" date and time$/ do |datetime, datetime_label|
  select_datetime(datetime, :from => datetime_label)
end

# Use this step in conjunction with Rail's time_select helper. For example:
# When I select "2:20PM" as the time
# Note: Rail's default time helper provides 24-hour time-- not 12 hour time. Webrat
# will convert the 2:20PM to 14:20 and then select it.
When /^I select "([^\"]*)" as the time$/ do |time|
  select_time(time)
end

# Use this step when using multiple time_select helpers on a page or you want to
# specify the name of the time on the form.  For example:
# When I select "7:30AM" as the "Gym" time
When /^I select "([^\"]*)" as the "([^\"]*)" time$/ do |time, time_label|
  select_time(time, :from => time_label)
end

# Use this step in conjunction with Rail's date_select helper.  For example:
# When I select "February 20, 1981" as the date
When /^I select "([^\"]*)" as the date$/ do |date|
  select_date(date)
end

# Use this step when using multiple date_select helpers on one page or
# you want to specify the name of the date on the form. For example:
# When I select "April 26, 1982" as the "Date of Birth" date
When /^I select "([^\"]*)" as the "([^\"]*)" date$/ do |date, date_label|
  select_date(date, :from => date_label)
end

When /^I check "([^\"]*)"$/ do |field|
  check(field) unless find_field(field)[:checked]
end

When /^I uncheck "([^\"]*)"$/ do |field|
  uncheck(field) if find_field(field)[:checked]
end

When /^I choose "([^\"]*)"$/ do |field|
  choose(field)
end

When /^I attach the file at "([^\"]*)" to "([^\"]*)"$/ do |path, field|
  attach_file(field, "#{RAILS_ROOT}/#{path}")
end

When /^I attach a "(\d+)" MB file called "([^\"]*)" to "([^\"]*)"$/ do |size,name,field|
  size = (1024*1024)*size.to_i
  File.open("#{RAILS_ROOT}/tmp/cucumber/example_files/#{name}","wb") { |f| f.seek(size-1); f.write("\0") }
  attach_file(field, "#{RAILS_ROOT}/tmp/cucumber/example_files/#{name}")
end

Then /^I should see "([^\"]*)"$/ do |text|
  page.should have_content(text)
  page.should_not have_css('span.translation_missing')
end

Then /^I should see "([^\"]*)" within "([^\"]*)"$/ do |text, selector|
  within(:css,selector) do
    page.should have_content(text)
  end
end

Then /^I should see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)
  page.should have_content(regexp)
end

Then /^I should see \/([^\/]*)\/ within "([^\"]*)"$/ do |regexp, selector|
  within(:css,selector) do
    regexp = Regexp.new(regexp)
    page.should have_content(regexp)
  end
end

Then /^I should not see "([^\"]*)"$/ do |text|
  page.should_not have_content(text)
end

Then /^I should not see "([^\"]*)" within "([^\"]*)"$/ do |text, selector|
  within(:css,selector) do
    page.should_not have_content(text)
  end
end

Then /^I should not see \/([^\/]*)\/$/ do |regexp|
  regexp = Regexp.new(regexp)
  response.should_not have_content(regexp)
end

Then /^I should not see \/([^\/]*)\/ within "([^\"]*)"$/ do |regexp, selector|
  within(:css,selector) do
    regexp = Regexp.new(regexp)
    page.should_not have_content(regexp)
  end
end

Then /^the "([^\"]*)" field should contain "([^\"]*)"$/ do |field, value|
  field_labeled(field).value.should =~ /#{value}/
end

Then /^the "([^\"]*)" field should not contain "([^\"]*)"$/ do |field, value|
  field_labeled(field).value.should_not =~ /#{value}/
end

Then /^the "([^\"]*)" checkbox should be checked$/ do |label|
  field_labeled(label)[:checked].should == true
end

Then /^the "([^\"]*)" checkbox should not be checked$/ do |label|
  field_labeled(label)[:checked].should == false
end

Then /^I should be on (.+)$/ do |page_name|
  URI.parse(current_url).path.should == path_to(page_name)
end

Then /^show me the page$/ do
  save_and_open_page
end