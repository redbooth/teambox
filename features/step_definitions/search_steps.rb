When /^the search index is re(indexed|built)$/ do |action|
  ts_reindex(action == 'built')
  # seems to be necessary before hitting sphinx
  sleep(0.2)
end

When /^I fill in the search box with "(.+)"$/ do |value|
  When(%(I fill in "q" with "#{value}"))
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
