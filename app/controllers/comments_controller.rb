class CommentsController < ApplicationController
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end
  
  def create
    # pass the project as extra parameter so target.project doesn't reload it
    authorize! :comment, target, @current_project
    
    comment = target.comments.create_by_user current_user, params[:comment]
    
    respond_to do |wants|
      wants.html {
        if request.xhr? or iframe?
          if comment.new_record?
            output_errors_json(comment)
          else
            render :partial => 'comments/comment',
              :locals => { :comment => comment, :threaded => true }
          end
        else
          redirect_to :back
        end
      }
    end
  end
  
  protected
  
  def target
    # can't use `memoize` because it freezes the object
    @target ||= if params[:conversation_id]
      @current_project.conversations.find params[:conversation_id]
    else
      @current_project.tasks.find params[:task_id]
    end
  end
  
end
