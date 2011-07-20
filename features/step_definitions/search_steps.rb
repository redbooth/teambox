When /^the search index is re(indexed|built)$/ do |action|
  ts_reindex(action == 'built')
  # seems to be necessary before hitting sphinx
  sleep(0.2)
end

When /^I fill in the search box with "(.+)"$/ do |value|
  When(%(I fill in "q" with "#{value}"))
end

When /^I submit the search/ do
  if Capybara.current_driver == Capybara.javascript_driver
    within(:xpath, "//form[@id='search']") do
      locate(:xpath, "//input[@name='q']").node.send_keys(:return)
    end
  else
    # Not Implemented yet
  end
end

Given /^there is a conversation titled "(.+)" in the project "(.+)"$/ do |title, project_name|
  Factory(:conversation,
    :name => title,
    :project => Project.find_by_name(project_name)
  )
end

Given /^there is a conversation with body "(.+?)" in the project "(.+?)"$/ do |body, project_name|
  Factory(:simple_conversation,
    :body => body,
    :project => Project.find_by_name(project_name)
  )
end

Given /^there is a task titled "(.+)" in the project "(.+)"$/ do |title, project_name|
  Factory(:conversation,
    :name => title,
    :project => Project.find_by_name(project_name)
  )
end

When /^I search for "(.+)"$/ do |terms|
  When %(I go to the results page for "#{terms}")
end

Then /^(?:|I )should see "([^\"]*)" in the results$/ do |text|
  if Capybara.current_driver == Capybara.javascript_driver
    page.has_xpath?(XPath::HTML.content(text), :visible => true)
  elsif page.respond_to? :should
    page.should have_content(text)
  else
    assert page.has_content?(text)
  end
end

Then /^(?:|I )should not see "([^\"]*)" in the results$/ do |text|
  if Capybara.current_driver == Capybara.javascript_driver
    assert page.has_no_xpath?(XPath::HTML.content(text), :visible => true)
  elsif page.respond_to? :should
    page.should_not have_content(text)
  else
    assert page.has_no_content?(text)
  end
end
