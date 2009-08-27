module CommentsHelper
  def new_comment_form(project,target = nil)
    if target.nil?
      form_url = [project,Comment.new]
    else
      form_url = [project,target,Comment.new]
    end
    render :partial => 'comments/form', :locals => { :target => target, :form_url => form_url }
  end
  
  def list_comments(comments)
    render :partial => 'comments/comment', :collection => comments
  end
  
  def edit_comment_link(comment)
    link_to_remote 'edit', 
      :url => edit_comment_path(comment),
      :method => :get
  end
  
  def comment_fields(f)
    render :partial => 'comments/fields', :locals => { :f => f }
  end
  
  def cancel_edit_comment_link(comment)
    link_to_remote 'cancel',
      :url => comment_path(comment),
      :method => :get
  end
  
  def delete_comment_link(comment)
    link_to_remote 'delete',
      :url => comment_path(comment),
      :method => :delete,
      :confirm => t('.confirm_delete')
  end
end