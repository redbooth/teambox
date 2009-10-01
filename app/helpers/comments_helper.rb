module CommentsHelper

  def add_hours_link(f)
    render :partial => 'comments/hours', :locals => { :f => f }
  end

  def activity_comment_icon(comment)
    if is_controller? :projects
      "<p class='activity_icon'>#{image_tag("activity_#{comment.target_type.to_s.underscore}.jpg")}</p>"
    end        
  end

  def comment_user_link(comment)
    unless is_controller? :projects
      link_to comment.user.name, user_path(comment.user)
    end  
  end

  def activity_comment_user_link(comment)
    if is_controller? :projects
      "<span class='author'>#{link_to comment.user.name, user_path(comment.user)}</span>"
    end  
  end

  def activity_comment_project_link(comment)
    if is_controller? :projects, :index
      "<span class='arr'>&rarr;</span> <span class='project'>#{link_to(comment.project.name, project_path(comment.project))}</span>"
    end
  end
  
  def activity_comment_target_link(comment)
    if is_controller? :projects
      case comment.target_type
        when 'Conversation'
          "<span class='arr'>&rarr;</span> #{link_to_conversation(comment.target.target)}"
        when 'Task'
          "<span class='arr'>&rarr;</span> #{link_to_task(comment.target.target)}"
        when 'TaskList'
          "<span class='arr'>&rarr;</span> #{link_to_task_list(comment.target.target)}"
      end
    end
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

  def new_comment_form(project,target = nil)
    if target.nil?
      form_url = [project,Comment.new]
    elsif target.class.to_s == 'Task'
      form_url = [project,target.task_list,target,Comment.new]
    else
      form_url = [project,target,Comment.new]
    end
    render :partial => 'comments/new', 
      :locals => { :target => target, 
        :form_url => form_url, :comment => project.comments.new }
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
    link_to_remote 'cancel',
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