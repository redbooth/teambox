module ConversationsHelper
  def new_conversation_link(project)
    link_to 'New Conversation', new_project_conversation_path(project)
  end
  
  def conversation_fields(f)
    render :partial => 'conversations/fields', :locals => { :f => f }
  end
  
  def list_conversations(conversations)
    render :partial => 'conversations/conversation', :collection => conversations
  end
  
  def conversation_link(project,conversation)
    link_to h(conversation.name), project_conversation_path(project,conversation)
  end
end