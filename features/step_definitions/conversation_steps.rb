Given /^the following conversation? with associations exists?:?$/ do |table|
  table.hashes.each do |hash|
    Factory(:conversation,
      :name => hash[:name],
      :user => User.find_by_login(hash[:user]),
      :project => Project.find_by_name(hash[:project])
    )
  end
end

Given /^I started a conversation named "([^\"]+)"$/ do |name|
  Factory(:conversation, :user => @current_user, :project => @current_project, :name => name)
end

Given /^the conversation "([^\"]+)" is watched by (@.+)$/ do |name, users|
  conversation = Conversation.find_by_name(name)
  
  each_user(users) do |user|
    conversation.add_watcher(user, false)
  end
  
  conversation.save(false)
end

Given /^(@.+) stops? watching the conversation "([^\"]*)"$/ do |users, name|
  conversation = Conversation.find_by_name(name)
  
  each_user(users) do |user|
    conversation.remove_watcher(user, false)
  end
  
  conversation.save(false)
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
