class ApiV1::CommentsController < ApiV1::APIController
  before_filter :load_target
  before_filter :load_comment, :only => [:update, :convert, :show, :destroy]
  
  def index
    authorize! :show, @target||current_user
    
    context = @target ?  @target.comments.where(api_scope) : 
                         Comment.joins(:project).where(:project_id => current_user.project_ids, :projects => {:archived => false}).where(api_scope)
    
    @comments = context.except(:order).
                        where(api_range('comments')).
                        where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
                        joins("LEFT JOIN watchers ON (comments.target_id = watchers.watchable_id AND watchers.watchable_type = comments.target_type) AND watchers.user_id = #{current_user.id}").     
                        limit(api_limit).
                        order('comments.id DESC').
                        includes([:target, :assigned, :previous_assigned, :user])
    
    api_respond @comments, :references => true
  end

  def show
    authorize! :show, @comment
    api_respond @comment, :references => true, :include => [:uploads]
  end
  
  def create
    # pass the project as extra parameter so target.project doesn't reload it
    authorize! :comment, @target, @current_project
    
    @comment = @target.comments.create_by_user current_user, params
    
    if @comment.save
      handle_api_success(@comment, :is_new => true, :references => true, :include => [:uploads])
    else
      handle_api_error(@comment)
    end
  end
  
  def update
    authorize! :update, @comment
    
    if @comment.update_attributes params
      handle_api_success(@comment, :is_new => true, :references => true, :include => [:uploads])
    else
      handle_api_error(@comment)
    end
  end
  
  def destroy
    authorize! :destroy, @comment
    @comment.do_rollback = true
    @comment.destroy
    
    handle_api_success(@comment)
  end
  
  protected

  def load_comment
    @comment = if @target
      @target.comments.find_by_id(params[:id])
    else
      Comment.where({:project_id => current_user.project_ids}).find_by_id(params[:id])
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

  def load_target
    # can't use `memoize` because it freezes the object
    begin
      @target ||= if params[:conversation_id]
        Conversation.where(:project_id => @current_project.try(:id)||current_user.project_ids).
                     find(params[:conversation_id])
      elsif params[:task_id]
        Task.where(:project_id => @current_project.try(:id)||current_user.project_ids).
             find(params[:task_id])
      else
        @current_project
      end
    rescue ActiveRecord::RecordNotFound
      api_error :not_found, :type => 'ObjectNotFound', :message => 'Comment not found'
    end
  end
  
end