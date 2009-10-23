module ConversationsHelper

  def conversation_action_links(project,conversation)
    if conversation.owner?(current_user)
      render :partial => 'conversations/actions',
      :locals => { 
        :project => project,
        :conversation => conversation }
    end
  end

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
    link_to content_tag(:span, t('.new_conversation')), new_project_conversation_path(project), :class => 'button'
  end
  
  def conversation_fields(f)
    render :partial => 'conversations/fields', :locals => { :f => f }
  end
  
  def list_conversations(conversations,conversation = nil)
    render :partial => 'conversations/conversation', :collection => conversations, :locals => { :conversation => conversation }
  end
  
  def conversation_link(conversation)
    link_to h(conversation.name), project_conversation_path(conversation.project,conversation), :class => 'conversation_link'
  end

  def edit_conversation_link(project,conversation)
    link_to pencil_image, edit_project_conversation_path(project,conversation)
  end
  
  def delete_conversation_link(project,conversation)
    link_to trash_image, project_conversation_path(project,conversation), :method => :delete
  end
  
  def conversation_comments_count(conversation)
    pluralize(conversation.comments.size, t('.message'), t('.messages'))
  end
  
  def conversation_comments_link(project,conversation)
    link_to conversation_comments_count(conversation), project_conversation_path(project,conversation)
  end
  
  def conversation_column(project,conversations,options={})
    options[:conversation] ||= nil
    options[:show_conversation_settings] ||= false
    options[:show_comments_settings] ||= false
    
    render :partial => 'conversations/column', :locals => {
        :project => project,
        :conversations => conversations,
        :conversation => options[:conversation],
        :show_conversation_settings =>  options[:show_conversation_settings],
        :show_comments_settings => options[:show_comments_settings] }
  end

  def set_conversation_class(conversation,current_conversation = nil)
    if conversation == current_conversation
      "selected"
    else
      ""
    end
  end

end