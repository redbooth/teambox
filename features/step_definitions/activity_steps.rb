Given /^I am in the project called "([^"]*)" the following comments:$/ do |project, table|
  Given %(I am in the project called "#{project}")

  @project = Project.find_by_name(project)

  table.hashes.collect{ |c| c[:conversation] }.uniq.each do |conversation|
    Factory(:conversation, :name => conversation, :project => @project) unless Conversation.find_by_name(conversation)
  end

  table.hashes.each do |hash|
    Factory(:comment,
      :body => hash[:body],
      :target => Conversation.find_by_name(hash[:conversation]),
      :project => @project
    )
  end
end

Given /^(\d+) comments are created in the project "([^"]*)"$/ do |count, project|
  @conversation = Factory(:simple_conversation, :project => Project.find_by_name(project))

  (1..count.to_i).each do
    Factory(:comment, :target => @conversation)
  end
end