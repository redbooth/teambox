module CommentsHelper

  def comment_form_for(form_url,&proc)
    remote_form_for form_url, 
      :loading => loading_new_comment_form,
      :id => 'new_comment_form',
      :html => {:preview => preview_project_comments_path(@current_project)},
      &proc
  end

  def non_js_comment_form_for(form_url,&proc)
    form_for form_url, 
      :loading => loading_new_comment_form,
      :id => 'new_comment_form',
      :html => {:preview => preview_project_comments_path(@current_project)},
      &proc
  end

  def loading_new_comment_form
    update_page do |page|
      page[js_id(:new_submit,Comment.new)].hide
      page[js_id(:new_loading,Comment.new)].show
      page['new_comment'].closePreview
    end  
  end

  def options_for_people(people, include_nobody = true)
    p = include_nobody ? [[t('.assigned_to_nobody'),nil]] : []
    people.sort_by{|a| a.name}.each {|person| p << [ person.name, person.id ]}
    p
  end
  
  def options_for_task_statuses
    t = []
    Task::STATUSES.to_enum(:each_with_index).each { |e,i| t << [e,i] unless i == 0 }
    t
  end

  def conversation_last_comment_text(comment)
    if is_controller? :conversations, :index
      "Last Comment by"
    end  
  end
  
  def add_hours_link(f)
    render :partial => 'comments/hours', :locals => { :f => f }
  end

  def activity_comment_icon(comment,unread)
    if is_controller? :projects
      "<div class='activity_icon activity_#{comment.target_type.to_s.underscore}#{'_unread' if unread}'><!-- --></div>"
    end        
  end

  def activity_comment_user_link(comment)
    if comment.user.deleted_at
      "<span class='author' style='text-decoration: line-through'>#{comment.user.name}</span>"
    else
      content_tag :span,
        link_to(comment.user.name, user_path(comment.user)),
        :class => 'author'

    end
  end
  
  def activity_comment_target_link(comment, connector = "&rarr;")
    link = case comment.target_type
      when 'Conversation'
        link_to_conversation(comment.target.target)
      when 'Task'
        link_to_task(comment.target.target)
      when 'TaskList'
        link_to_task_list(comment.target.target)
    end
    
    "<span class='arr target_arr'>#{connector}</span> <span class='target'>#{link}</span>" if link
  end

  def comment_actions_link(comment)
    render :partial => 'comments/actions', :locals => {
      :comment => comment }
  end
  
  def comments_settings
    render :partial => 'comments/settings'
  end

  def new_hour_comment_form(project,comment)
    render :partial => 'comments/new', 
      :locals => { :target => nil, 
        :form_url => [project,comment], 
        :comment => comment,
        :show_hours => true }
  end

  def new_comment_user_form(user,comment,options={})
    message = options[:message] ||= nil
    render :partial => 'comments/new',
      :locals => { :target => user,
        :message => message,
        :form_url => [user,comment], 
        :comment => comment }
  end

  def new_comment_form(project,comment,options={})
    message = options[:message] ||= nil
    target  = options[:target]  ||= nil
    if target.nil?
      form_url = [project,comment]
    elsif target.is_a?(Task)
      form_url = [project,target.task_list,target,comment]
    else
      form_url = [project,target,comment]
    end
    if project.commentable?(current_user) && project.archived == false
      render :partial => 'comments/new',
        :locals => { :target => target,
          :message => message,
          :form_url => form_url, 
          :comment => comment }
    end
  end
  
  def list_comments(comments,target)
    content_tag :div,
    render(:partial => 'comments/list_comments',
      :locals => {
        :comments => comments,
        :target => target }),
      :class => 'comments',
      :id => 'comments'
  end
  
  def comment_fields(f,comment,show_hours)
    render :partial => 'comments/fields', :locals => { :f => f, :comment => comment, :show_hours => show_hours }
  end
  
  def cancel_edit_comment_link(comment)
    link_to_remote t('common.cancel'),
      :url => project_comment_path(comment.project, comment),
      :method => :get,
      :loading => show_loading_comment_form(comment.id)
  end

  def edit_comment_link(comment)
    return unless comment.user_id == current_user.id
    link_to_remote pencil_image,
      :url => edit_project_comment_path(comment.project, comment),
      :loading => edit_comment_loading_action(comment),
      :method => :get,
      :html => {:id => "edit_comment_#{comment.id}_link"}
  end
    
  def delete_comment_link(comment)
    link_to_remote trash_image,
      :url => project_comment_path(comment.project, comment),
      :loading => delete_comment_loading_action(comment),
      :method => :delete,
      :confirm => t('.confirm_delete'),
      :html => {:id => "delete_comment_#{comment.id}_link"}
  end
  
  def show_loading_comment_form(id)
    update_page do |page|
      page["comment_form_loading_#{id}"].show
      page["comment_submit_#{id}"].hide
    end
  end
  
  def hide_loading_comment_form(id)
    page.remove "comment_form_loading_#{id}"
    page["comment_submit_#{id}"].show
  end
  
  def loading_comment_form(toggle,id)
    if toggle
      page["note_form_loading#{"_#{id}" if id}"].show
      page["note_submit#{"_#{id}" if id}"].hide
    else
      page["note_form_loading#{"_#{id}" if id}"].hide
      page["note_submit#{"_#{id}" if id}"].show
    end
  end
  
  def edit_comment_loading_action(comment)
    update_page do |page|
      page.insert_html :after, "edit_comment_#{comment.id}_link", loading_action_image("edit_comment_#{comment.id}")
      page["edit_comment_#{comment.id}_link"].hide
    end  
  end
  
  def delete_comment_loading_action(comment)
    update_page do |page|
      page.insert_html :after, "delete_comment_#{comment.id}_link", loading_action_image("delete_comment_#{comment.id}")
      page["delete_comment_#{comment.id}_link"].hide
    end  
  end
  
  def last_comment_input
    hidden_field_tag 'last_comment_id', '0'
  end
  
  def comment_update_last_id
    javascript_tag <<-EOS
      var last = $$('#comments .comment:first');
      if (last.length > 0)
      {
        var val = $(last[0]).readAttribute('id').split('_')[1];
        $('last_comment_id').writeAttribute('value', val);
      }
    EOS
  end
  
  def comments_script(target)
    if target.is_a? Project
      project = target
    else
      project = target.project
    end
      
    update_page_tag do |page|
      page.assign('comments_update_url',get_comments_project_path(project))
      page.assign('comments_parameters', { :target_name => target.class.name, :target_id => target.id })
    end
  end

  def comments_count(target,status_type)
    target.comments_count ||= 0
    id = comment_count_type(target,status_type)
    render :partial => 'comments/comment_count',
      :locals => {
        :id => id,
        :target => target,
        :status_type => status_type }
  end

  def comment_count_type(target,status_type)
    unless [:column,:content,:header].include?(status_type)
      raise ArgumentError, "Invalid Comment Count type, was expecting :column, :content or :header but got #{status_type}"
    end
    id = "#{js_id(target)}_#{status_type}_comments_count"
  end

  def make_autocompletable(element_id)
    base_list = ["'@all <span class=\"informal\">#{t('conversations.watcher_fields.people_all')}</span>'"]
    people_list = (base_list + @current_project.people.map{|m| "'@#{m.login} <span class=\"informal\">#{h(m.name)}</span>'"}).join(',')
    javascript_tag "Comment.make_autocomplete('comment_body', [#{people_list}]);"
  end

  def comment_text_area(f, target)
    placeholder = case target
    when Conversation then t('.conversation')
    when TaskList then t('.task_list')
    when Task then t('.task')
    else t('.project')
    end

    f.text_area :body, :class => 'comment_body', :id => 'comment_body', :placeholder => placeholder
  end

end