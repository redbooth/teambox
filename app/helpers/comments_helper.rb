module CommentsHelper


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
    "<span class='author'>#{link_to comment.user.name, user_path(comment.user)}</span>"
  end
  
  def activity_comment_target_link(comment)
    link = case comment.target_type
      when 'Conversation'
        link_to_conversation(comment.target.target)
      when 'Task'
        link_to_task(comment.target.target)
      when 'TaskList'
        link_to_task_list(comment.target.target)
    end
    
    "<span class='arr target_arr'>&rarr;</span> <span class='target'>#{link}</span>" if link
  end

  def comment_actions_link(comment)
    render :partial => 'comments/actions', :locals => {
      :comment => comment }
  end
  
  def comments_settings
    render :partial => 'comments/settings'
  end

  def new_hour_comment_form(project)
    render :partial => 'comments/new', 
      :locals => { :target => nil, 
        :form_url => [project,Comment.new], 
        :comment => project.comments.new,
        :show_hours => true }
  end

  def new_comment_user_form(user,options={})
    message = options[:message] ||= nil
    render :partial => 'comments/new',
      :locals => { :target => user,
        :message => message,
        :form_url => [user,Comment.new], 
        :comment => Comment.new }    
  end

  def new_comment_form(project,options={})
    message = options[:message] ||= nil
    target  = options[:target]  ||= nil
    if target.nil?
      form_url = [project,Comment.new]
    elsif target.class.to_s == 'Task'
      form_url = [project,target.task_list,target,Comment.new]
    else
      form_url = [project,target,Comment.new]
    end
    render :partial => 'comments/new',
      :locals => { :target => target,
        :message => message,
        :form_url => form_url, 
        :comment => project.comments.new }
  end
  
  def list_comments(comments,target)
    render :partial => 'comments/list_comments', :locals => { :comments => comments, :target => target }
  end
  
  def show_comment(comment)
    render :partial => 'comments/comment', :locals => { :comment => comment }
  end

  def comment_fields(f,comment,show_hours)
    render :partial => 'comments/fields', :locals => { :f => f, :comment => comment, :show_hours => show_hours }
  end
  
  def cancel_edit_comment_link(comment)
    link_to_remote t('common.cancel'),
      :url => comment_path(comment),
      :method => :get
  end

  def edit_comment_link(comment)
    link_to_remote pencil_image,
      :url => edit_comment_path(comment),
      :method => :get
  end
    
  def delete_comment_link(comment)
    link_to_remote trash_image,
      :url => comment_path(comment),
      :method => :delete,
      :confirm => t('.confirm_delete')
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
  
end