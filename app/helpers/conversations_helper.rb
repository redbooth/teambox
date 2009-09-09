module ConversationsHelper
  def new_conversation_link(project)
    link_to 'New Conversation', new_project_conversation_path(project)
  end
  
  def conversation_fields(f)
    render :partial => 'conversations/fields', :locals => { :f => f }
  end
  
  def list_conversations(conversations,current_conversation = nil)
    render :partial => 'conversations/conversation', :collection => conversations, :locals => { :current_conversation => current_conversation }
  end
  
  def conversation_link(project,conversation)
    link_to h(conversation.name), project_conversation_path(project,conversation)
  end

  def edit_conversation_link(text,project,conversation)
    link_to h(text), edit_project_conversation_path(project,conversation)
  end
  
  def conversation_comments_count(conversation)
    pluralize(conversation.comments.size, t('shared.common.comment'), t('shared.common.comments'))
  end
  
  def conversation_comments_link(project,conversation)
    link_to conversation_comments_count(conversation), project_conversation_path(project,conversation)
  end
  
  def conversation_column(project,conversations,current_conversation = nil)
    render :partial => 'conversations/column', :locals => {
        :project => project,
        :conversations => conversations,
        :current_conversation => current_conversation }
  end
  
  def conversation_class(conversation,current_conversation = nil)
    if conversation == current_conversation
      "selected"
    else
      ""
    end
  end
end