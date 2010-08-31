module ConversationsHelper
  
  def conversation_id(element,project,conversation=nil)
    conversation ||= project.conversations.new
    js_id(element,project,conversation)
  end

  def conversation_form_for(project,conversation,&proc)
    unobtrusive_app_form_for(project,conversation,&proc)
  end

  def conversation_submit(project,conversation)
    unobtrusive_app_submit(project,conversation)
  end
  
  # Jenny helpers

  def new_conversation_url(project,conversation)
    new_project_task_list_path(project)
  end
  
  def edit_conversation_url(project,conversation)
    edit_project_conversation_path(project, conversation)
  end
  
  def show_conversation(project,conversation)
    unobtrusive_app_toggle(project,conversation)
  end  

  def hide_conversation(project,conversation)
    unobtrusive_app_toggle(project,conversation)
  end
  
  #

  def conversation_form(project,conversation)
    render 'conversations/form', :project => project, :conversation => conversation
  end
  
  def conversations_primer(project)
    if project.editable?(current_user)
      render 'conversations/primer', :project => project
    end
  end
  
  def new_conversation_link(project)
    link_to content_tag(:span, t('.new_conversation')), new_project_conversation_path(project), 
      :class => 'add_button', :title => 'new_conversation_link'
  end
    
  def the_conversation_link(conversation)
    link_to h(conversation.name), project_conversation_path(conversation.project,conversation), :class => 'conversation_link'
  end
  
  def conversation_comment(conversation)
    if comment = conversation.comments.first
      render 'comments/comment', :comment => comment
    end
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
    
    render 'conversations/column',
      :project => project,
      :conversations => conversations,
      :conversation => options[:conversation],
      :show_conversation_settings =>  options[:show_conversation_settings]
  end

end