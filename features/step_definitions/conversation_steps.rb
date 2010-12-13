Given /^the following conversation? with associations exists?:?$/ do |table|
  table.hashes.each do |hash|
    Factory(:conversation,
      :name => hash[:name],
      :user => User.find_by_login(hash[:user]),
      :project => Project.find_by_name(hash[:project])
    )
  end
end

Given /^I started a conversation named "([^\"]+)"(?: in the "([^\"]*)" project)?$/ do |name, project_name|
  Factory(:conversation, :user => @current_user, :project => (project_name ? Project.find_by_name(project_name) : @current_project), :name => name)
end

Given /^I started a simple conversation(?: in the "([^\"]*)" project)?$/ do |project_name|
  Factory(:conversation, :user => @current_user, :project => (project_name ? Project.find_by_name(project_name) : @current_project), :name => nil, :simple => true)
end

Given /^the conversation "([^\"]+)" is watched by (@.+)$/ do |name, users|
  conversation = Conversation.find_by_name(name)
  
  each_user(users) do |user|
    conversation.add_watcher(user, false)
  end
  
  conversation.save(:validate => false)
end

Given /^(@.+) stops? watching the conversation "([^\"]*)"$/ do |users, name|
  conversation = Conversation.find_by_name(name)
  
  each_user(users) do |user|
    conversation.remove_watcher(user, false)
  end
  
  conversation.save(:validate => false)
end

Then /^(@.+) should( not)? be watching the conversation "([^\"]*)"$/ do |users, negate, name|
  conversation = Conversation.find_by_name(name)
  
  each_user(users) do |user|
    if negate.blank?
      user.should be_watching(conversation)
    else
      user.should_not be_watching(conversation)
    end
  end
end

When /^(?:|I )fill in the conversation's comment box with "([^\"]*)"(?: within "([^\"]*)")?$/ do |value, selector|
  with_scope(selector) do
    xpath = Capybara::XPath.append('//form[contains(@class,"edit_conversation")]//*[@id="conversation_comments_attributes_0_body"]')
    locate(:xpath, xpath, "cannot fill in: no conversation comment textarea found").set(value)
  end
end

When /^(?:|I )click the conversation's comment box(?: within "([^\"]*)")?$/ do |selector|
  with_scope(selector) do
    xpath = Capybara::XPath.append('//form[contains(@class,"edit_conversation")]//*[@name="comment[body]"]')
    locate(:xpath, xpath, "cannot click: no conversation comment textarea found").click
  end
end

Then /^I should see the error "([^\"]*)"(?: within "([^\"]*)")?$/ do |msg, selector|
  with_scope(selector) do
    comment = all("span.error").last.text
    comment.should match(/#{msg}/)
  end
end

Then /^I should see "([^\"]+)" in the thread title$/ do |msg|
  link = false
  wait_until do
    link = find("p.thread_title a")
  end
  comment = link.text
  comment.should match(/#{msg}/)
end

Then /^I should see "([^\"]+)" in the page title$/ do |msg|
  header = false
  wait_until do
    header = find("h2")
  end
  title = header.text
  title.should match(/#{msg}/)
end

Then /^I should see "([^\"]+)" in the thread starter$/ do |msg|
  comment = all("p.starter").last.text.strip
  comment.should match(/#{msg}/)
end
