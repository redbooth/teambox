module ConversationsHelper

  def conversation_comment(conversation)
    if current_user.conversations_first_comment
      render :partial => 'comments/comment', :locals => { :comment => conversation.comments.first }
    else
      render :partial => 'comments/comment', :locals => { :comment => conversation.comments.last }
    end  
    
  end
  
  def list_short_conversations(conversations)
    render :partial => 'conversations/short_conversation', :collection => conversations
  end
  
  def conversations_settings
    render :partial => 'conversations/settings'
  end
  
  def new_conversation_link(project)
    link_to add_image, new_project_conversation_path(project),
    :class => 'add_button'
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
    pluralize(conversation.comments.size, t('.comment'), t('.comments'))
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
  
  def update_conversation_comments(comments)
    page['comments'].update(list_comments(comments))
  end
  
  def conversation_script
    update_page_tag do |page|
      page.assign('conversation_id',@current_conversation.id)
      page.assign('conversation_update_url',update_comments_project_conversation_path(@current_project,@current_conversation))
    end
  end
end