module CommentsHelper

  def comment_form_for(form_url,&proc)
    form_for form_url,
      :html => {:update_id => js_id(nil,Comment.new)},
      &proc
  end
  
  def convert_comment_form_for(comment,&proc)
    form_for [comment.project,comment],
      :url => convert_project_comment_path(comment.project,comment),
      :html => {
        :id => js_id(:convert,comment.project,comment),
        :class => 'convert_comment'
      },
      &proc
  end
  
  def edit_comment_form_for(comment,&proc)
    form_for [comment.project,comment],
      :id => "comment_#{comment.id}_form",
      :method => :put,
      :html => {
        :class => 'edit_comment', 
        :update_id => js_id(nil,comment),
        :action_cancel => project_comment_path(comment.project,comment)},
      &proc
  end

  def non_js_comment_form_for(form_url,&proc)
    form_for form_url, 
      :loading => loading_new_comment_form,
      :id => 'new_comment_form',
      &proc
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
    link_to t('common.cancel'),
      project_comment_path(comment.project, comment),
      :class => 'edit_comment_cancel'
  end
  
  def cancel_convert_comment_link(comment)
    link_to t('common.cancel'),
      project_path(comment.project),
      :class => 'convert_comment_cancel'
  end
  
  def convert_comment_link(comment)
    link_to t('comments.actions.convert_task'),
      project_comment_path(comment.project, comment),
      :id => "convert_comment_#{comment.id}_link", 
      :class => 'commentConvert',
      :action_url => edit_project_comment_path(comment.project, comment, :part => 'task')
  end

  def edit_comment_link(comment)
    return unless comment.user_id == current_user.id
    link_to t('comments.actions.edit'),
      edit_project_comment_path(comment.project, comment),
      :id => "edit_comment_#{comment.id}_link", 
      :class => 'commentEdit taction',
      :action_url => edit_project_comment_path(comment.project, comment)
  end
    
  def delete_comment_link(comment)
    link_to t('common.delete'),
      project_comment_path(comment.project, comment),
      :id => "delete_comment_#{comment.id}_link", 
      :class => 'commentDelete taction',
      :aconfirm => t('.confirm_delete'),
      :action_url => project_comment_path(comment.project, comment)
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