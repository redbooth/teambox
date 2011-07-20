class ApiV1::CommentsController < ApiV1::APIController
  before_filter :load_comment, :only => [:update, :convert, :show, :destroy]
  
  def index
    query = {:conditions => api_range,
             :limit => api_limit,
             :order => 'id DESC',
             :include => [:target, :user]}
    
    @comments = if target
      target.comments.where(api_scope).all(query)
    else
      Comment.where(api_scope).find_all_by_project_id(current_user.project_ids, query)
    end
    
    api_respond @comments, :references => [:target, :user, :project]
  end

  def show
    api_respond @comment, :include => [:user]
  end
  
  def create
    # pass the project as extra parameter so target.project doesn't reload it
    authorize! :comment, target, @current_project
    
    @comment = target.comments.create_by_user current_user, params
    
    if @comment.save
      handle_api_success(@comment, :is_new => true)
    else
      handle_api_error(@comment)
    end
  end
  
  def update
    authorize! :update, @comment
    
    if @comment.update_attributes params
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
    api_error :not_found, :type => 'ObjectNotFound', :message => 'Comment not found' unless @comment
  end
  
  def api_scope
    conditions = {}
    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end
    unless params[:target_type].nil?
      conditions[:target_type] = params[:target_type]
    end
    conditions
  end

  def target
    # can't use `memoize` because it freezes the object
    @target ||= if params[:conversation_id]
      Conversation.find_by_id params[:conversation_id],
                              :conditions => {:project_id => @current_project.try(:id)||current_user.project_ids}
    elsif params[:task_id]
      Task.find_by_id params[:task_id],
                      :conditions => {:project_id => @current_project.try(:id)||current_user.project_ids}
    else
      @current_project
    end
  end
  
end