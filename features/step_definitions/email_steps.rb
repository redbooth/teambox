# Commonly used email steps
#
# To add your own steps make a custom_email_steps.rb
# The provided methods are:
#
# last_email_address
# reset_mailer
# open_last_email
# visit_in_email
# unread_emails_for
# mailbox_for
# current_email
# open_email
# read_emails_for
# find_email
#
# General form for email scenarios are:
#   - clear the email queue (done automatically by email_spec)
#   - execute steps that sends an email
#   - check the user received an/no/[0-9] emails
#   - open the email
#   - inspect the email contents
#   - interact with the email (e.g. click links)
#
# The Cucumber steps below are setup in this order.

module EmailHelpers
  def current_email_address
    # Replace with your a way to find your current email. e.g @current_user.email
    # last_email_address will return the last email address used by email spec to find an email.
    # Note that last_email_address will be reset after each Scenario.
    last_email_address || @current_user.email
  end
end

World(EmailHelpers)

#
# Reset the e-mail queue within a scenario.
# This is done automatically before each scenario.
#

Given /^(?:a clear email queue|no emails have been sent)$/ do
  reset_mailer
end

#
# Check how many emails have been sent/received
#

Then /^(?:I|they|"([^"]*?)") should receive (an|no|\d+) emails?$/ do |address, amount|
  unread_emails_for(address).size.should == parse_email_count(amount)
end

Then /^(@.+) should receive (an|no|\d+) emails?( with subject .+)?$/ do |users, amount, with_subject|
  each_user(users) do |user|
    Then %("#{user.email}" should receive #{amount} emails#{with_subject})
  end
end

Then /^(?:I|they|"([^"]*?)") should have (an|no|\d+) emails?$/ do |address, amount|
  mailbox_for(address).size.should == parse_email_count(amount)
end

#TODO: this could be added back in to the email_spec gem
Then /^(?:I|they|"([^"]*?)") should receive (an|no|\d+) emails? with subject "([^"]*?)"$/ do |address, amount, subject|
  unread_emails_for(address).select { |m| m.subject =~ Regexp.new(subject) }.size.should == parse_email_count(amount)
end

# DEPRECATED
# The following methods are left in for backwards compatibility and
# should be removed by version 0.3.5.
Then /^(?:I|they|"([^"]*?)") should not receive an email$/ do |address|
  email_spec_deprecate "The step 'I/they/[email] should not receive an email' is no longer supported.
                      Please use 'I/they/[email] should receive no emails' instead."
  unread_emails_for(address).size.should == 0
end

#
# Accessing emails
#

# Opens the most recently received email
When /^(?:I|they|"([^"]*?)") opens? the email$/ do |address|
  open_email(address)
end

When /^(?:I|they|"([^"]*?)") opens? the email with subject "([^"]*?)"$/ do |address, subject|
  open_email(address, :with_subject => subject)
end

When /^(?:I|they|"([^"]*?)") opens? the email with text "([^"]*?)"$/ do |address, text|
  open_email(address, :with_text => text)
end

When /^(@\w+) opens? the email( with subject .+)?$/ do |users, with_subject_or_text|
  each_user(users) do |user|
    Then %("#{user.email}" opens the email#{with_subject_or_text})
  end
end


#
# Inspect the Email Contents
#

Then /^(?:I|they|he|she) should see "([^"]*?)" in the email subject$/ do |text|
  current_email.should have_subject(Regexp.new(text))
end

Then /^(?:I|they|he|she) should see "([^"]*?)" in the email body$/ do |text|
  if current_email.multipart?
    Then %(I should see "#{text}" in the html part of the email body)
    Then %(I should see "#{text}" in the text part of the email body)
  else
    current_email.body.should =~ Regexp.new(text)
  end
end

Then /^(?:I|they|he|she) should see "([^"]*?)" in the html part of the email body$/ do |text|
  current_email.html_part.body.should =~ Regexp.new(text)
end

Then /^(?:I|they|he|she) should see "([^"]*?)" in the text part of the email body$/ do |text|
  current_email.text_part.body.should =~ Regexp.new(text)
end

Then /^(?:I|they|he|she) should not see "([^"]*?)" in the email body$/ do |text|
  if current_email.multipart?
    Then %(I should not see "#{text}" in the html part of the email body)
    Then %(I should not see "#{text}" in the text part of the email body)
  else
    current_email.body.should_not =~ Regexp.new(text)
  end
end

Then /^(?:I|they|he|she) should not see "([^"]*?)" in the html part of the email body$/ do |text|
  current_email.html_part.body.should_not =~ Regexp.new(text)
end

Then /^(?:I|they|he|she) should not see "([^"]*?)" in the text part of the email body$/ do |text|
  current_email.text_part.body.should_not =~ Regexp.new(text)
end

# DEPRECATED
# The following methods are left in for backwards compatibility and
# should be removed by version 0.3.5.
Then /^(?:I|they) should see "([^"]*?)" in the subject$/ do |text|
  email_spec_deprecate "The step 'I/they should see [text] in the subject' is no longer supported.
                      Please use 'I/they should see [text] in the email subject' instead."
  current_email.should have_subject(Regexp.new(text))
end
Then /^(?:I|they) should see "([^"]*?)" in the email$/ do |text|
  email_spec_deprecate "The step 'I/they should see [text] in the email' is no longer supported.
                      Please use 'I/they should see [text] in the email body' instead."
  current_email.body.should =~ Regexp.new(text)
end

#
# Interact with Email Contents
#

When /^(?:I|they) follow "([^"]*?)" in the email$/ do |link|
  visit_in_email(link)
end

When /^(?:I|they) click the first link in the email$/ do
  click_first_link_in_email
end

