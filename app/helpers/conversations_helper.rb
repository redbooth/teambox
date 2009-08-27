module ConversationsHelper
  def new_conversation_link(project)
    link_to 'New Conversation', new_project_conversation_path(project)
  end
  
  def conversation_fields(f)
    render :partial => 'conversations/fields', :locals => { :f => f }
  end
end