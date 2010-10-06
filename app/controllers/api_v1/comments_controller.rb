class ApiV1::CommentsController < ApiV1::APIController
  before_filter :load_comment, :only => [:update, :convert, :show, :destroy]
  
  def index
    params = {:conditions => api_range, :limit => api_limit, :include => [:target, :user]}
    
    @comments = if target
      target.comments.all(params)
    else
      Comment.find_all_by_project_id(current_user.project_ids, params)
    end
    
    api_respond @comments, :references => [:target, :user, :project]
  end

  def show
    api_respond @comment, :include => [:user]
  end
  
  def create
    # pass the project as extra parameter so target.project doesn't reload it
    authorize! :comment, target, @current_project
    
    @comment = target.comments.create_by_user current_user, params[:comment]
    
    if @comment.save
      handle_api_success(@comment, :is_new => true)
    else
      handle_api_error(@comment)
    end
  end
  
  def update
    authorize! :update, @comment
    
    if @comment.update_attributes params[:comment]
      handle_api_success(@comment, :is_new => true)
    else
      handle_api_error(@comment)
    end
  end
  
  def destroy
    authorize! :destroy, @comment
    @comment.destroy
    
    handle_api_success(@comment)
  end
  
  protected

  def load_comment
    @comment = if target
      target.comments.find params[:id]
    else
      Comment.find_by_id(params[:id], :conditions => {:project_id => current_user.project_ids})
    end
    api_status(:not_found) unless @comment
  end

  def target
    # can't use `memoize` because it freezes the object
    @target ||= if params[:conversation_id]
      @current_project.conversations.find params[:conversation_id]
    elsif params[:task_id]
      @current_project.tasks.find params[:task_id]
    else
      @current_project
    end
  end
  
end