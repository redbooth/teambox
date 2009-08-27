module CommentsHelper
  def new_comment_form(project,target = nil)
    if target.nil?
      form_url = [project,Comment.new]
    else
      form_url = [project,target,Comment.new]
    end
    render :partial => 'comments/form', :locals => { :target => target, :form_url => form_url }
  end
end