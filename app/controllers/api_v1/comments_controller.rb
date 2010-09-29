class ApiV1::CommentsController < ApiV1::APIController
  before_filter :load_comment, :only => [:update, :convert, :show, :destroy]
  
  def index
    @comments = target.comments.all(:conditions => api_range, :limit => api_limit, :include => [:target, :user])
    
    api_respond @comments, :references => (@comments.map(&:target) + @comments.map(&:user)).uniq.compact
  end

  def show
    api_respond @comment
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
    @comment = @current_project.comments.find params[:id]
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