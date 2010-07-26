Given /^the following conversation? with associations exists?:?$/ do |table|
  table.hashes.each do |hash|
    Factory(:conversation,
      :name => hash[:name],
      :user => User.find_by_login(hash[:user]),
      :project => Project.find_by_name(hash[:project])
    )
  end
end

Given /^"([^\"]*)" is watching the conversation "([^\"]*)"$/ do |username,name|
  conversation = Conversation.find_by_name(name)
  conversation.add_watcher User.find_by_login(username)
end

Then /^"([^\"]*)" should be watching the conversation "([^\"]*)"$/ do |username,name|
  conversation = Conversation.find_by_name(name)
  conversation.watching?(User.find_by_login(username))
end

Given /^"([^\"]*)" stops watching the conversation "([^\"]*)"$/ do |username,name|
  conversation = Conversation.find_by_name(name)
  conversation.remove_watcher User.find_by_login(username)
end

Then /^"([^\"]*)" should not be watching the conversation "([^\"]*)"$/ do |username,name|
  conversation = Conversation.find_by_name(name)
  !conversation.watching?(User.find_by_login(username))
end
