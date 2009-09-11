module CommentsHelper
  def new_comment_form(project,target = nil)
    if target.nil?
      form_url = [project,Comment.new]
    elsif target.class.to_s == 'Task'
      form_url = [project,target.task_list,target,Comment.new]
    else
      form_url = [project,target,Comment.new]
    end
    @comment = project.comments.new
    render :partial => 'comments/new', 
      :locals => { :target => target, 
        :form_url => form_url, :comment => @comment }
  end
  
  def list_comments(project,comments)
    render :partial => 'comments/comment', :collection => comments,
      :locals => {
        :project => project }
  end
  
  def show_comment(comment)
    render :partial => 'comments/comment', :locals => { :comment => comment }
  end
    
  def comment_fields(f)
    render :partial => 'comments/fields', :locals => { :f => f }
  end
  
  def cancel_edit_comment_link(comment)
    link_to_remote 'cancel',
      :url => comment_path(comment),
      :method => :get
  end

  def edit_comment_link(project,comment)
    link_to_remote pencil_image,
      :url => edit_project_comment_path(project,comment),
      :method => :get
  end
    
  def delete_comment_link(project,comment)
    link_to_remote trash_image,
      :url => project_comment_path(project,comment),
      :method => :delete,
      :confirm => t('.confirm_delete')
  end
end