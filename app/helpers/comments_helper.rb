module CommentsHelper

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