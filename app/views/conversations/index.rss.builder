rss_feed :root_url => project_conversations_url(@current_project) do |feed|
  feed.title t('.rss.title', :name => @current_project.name)
  feed.description t('.rss.description', :name => @current_project.name)
  
  for conversation in @conversations
    feed.entry conversation, :url => polymorphic_url([@current_project, conversation]) do |item|
      item.title conversation.name
      item.description conversation_comment(conversation)
      item.author conversation.user.name
    end
  end
end
