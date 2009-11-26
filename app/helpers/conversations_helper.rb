module ConversationsHelper

  def conversations_primer
    render :partial => 'conversations/primer'
  end

  def conversation_form(project,conversation)
    render :partial => 'conversations/form', :locals => {
      :project => project,
      :conversation => conversation }
  end

  def conversation_form_for(project,conversation,&proc)
    raise ArgumentError, "Missing block" unless block_given?
    action = conversation.new_record? ? 'new' : 'edit'
      
    remote_form_for([project,conversation],
      :loading => conversation_form_loading(action,project,conversation),
      :html => {
        :id => conversation_id("#{action}_form",project,conversation), 
        :class => 'conversation_form', 
        :style => 'display: none;'}, 
        &proc)
  end

  def conversation_submit(project,conversation)
    action = conversation.new_record? ? 'new' : 'edit'
    submit_id = conversation_id("#{action}_submit",project,conversation)
    loading_id = conversation_id("#{action}_loading",project,conversation)
    submit_to_function t("conversations.#{action}.submit"), hide_conversation(project,conversation), submit_id, loading_id
  end

  def hide_conversation(project,conversation)
    action = conversation.new_record? ? 'new' : 'edit'
    
    header_id = conversation_id("#{action}_header",project,conversation)
    link_id = conversation_id("#{action}_link",project,conversation)
    form_id = conversation_id("#{action}_form",project,conversation)
    
    update_page do |page|
      conversation.new_record? ? page[link_id].show : page[header_id].show
      page[form_id].hide
      page << "Form.reset('#{form_id}')"
    end  
  end


  def conversation_link(project,conversation)
    action = conversation.new_record? ? 'new' : 'edit'

    link_to_function content_tag(:span,t("conversations.link.#{action}")), show_task_list(project,conversation),
      :class => "#{action}_conversation_link",
      :id => conversation_id("#{action}_link",project,conversation)
  end
  
  def conversation_form_loading(action,project,conversation)
    update_page do |page|
      page[conversation_id("#{action}_submit",project,conversation)].hide
      page[conversation_id("#{action}_loading",project,conversation)].show
    end    
  end
  
  def conversation_header(project,conversation)
    render :partial => 'conversations/header', :locals => {
      :project => project,
      :conversation => conversation }
  end

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
    render :partial => 'conversations/short_conversation', 
      :as => :conversation,
      :collection => conversations
  end
  
  def conversations_settings
    render :partial => 'conversations/settings'
  end
  
  def new_conversation_link(project)
    link_to content_tag(:span, t('.new_conversation')), new_project_conversation_path(project), 
      :class => 'button', :title => 'new_conversation_link'
  end

  def conversation_watcher_fields(project,conversation)
    render :partial => 'conversations/watcher_fields', 
      :locals => { 
        :project => project, 
        :conversation => conversation }
  end

  
  def conversation_fields(f,project,conversation)
    render :partial => 'conversations/fields', 
      :locals => { 
        :f => f, 
        :project => project, 
        :conversation => conversation }
  end
  
  def list_conversations(project,conversations,current_target = nil)
    render :partial => 'conversations/conversation', 
      :collection => conversations, 
      :locals => { 
        :project => project,
        :current_target => current_target }
  end
  
  def the_conversation_link(conversation)
    link_to h(conversation.name), project_conversation_path(conversation.project,conversation), :class => 'conversation_link'
  end

  def edit_conversation_link(project,conversation)
    link_to t('common.edit'), edit_project_conversation_path(project,conversation)
  end
  
  def delete_conversation_link(project,conversation)
    link_to t('common.delete'), project_conversation_path(project,conversation), 
    :confirm => t('.confirm_delete'),
    :method => :delete
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
  
  def replace_conversation(project,conversation)
    page.replace conversation_id(:item,project,conversation),
      :partial => 'conversations/conversation', 
      :locals => { 
        :project => project,
        :conversation => conversation,
        :current_target => conversation }
  end

  def replace_conversation_header(project,conversation)
    page.replace conversation_id(:edit_header,project,conversation),
      :partial => 'conversations/header', 
      :locals => { 
        :project => project,
        :conversation => conversation }
  end


  def conversation_id(element,project,conversation)
    if conversation.new_record?
      "#{js_id([project,conversation])}_conversation_#{"#{element}" unless element.nil?}"
    else  
      "#{js_id([project,conversation])}_#{"#{element}" unless element.nil?}"
    end
  end


end