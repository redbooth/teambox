class ApiV1::ActivitiesController < ApiV1::APIController
  skip_before_filter :touch_user
  before_filter :get_target, :only => [:index]

  def index
    authorize! :show, @current_project||current_user
    
    @activities = Activity.where(api_scope).
      where(api_range('activities')).
      where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
      joins("LEFT JOIN watchers ON ((activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type) OR (activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type)) AND watchers.user_id = #{current_user.id}").
      order('activities.id DESC').
      limit(api_limit(:hard => true))

    @activities = @activities.threads.except(:order).by_thread if params[:threads]
    api_respond @activities, :references => true, :include => api_include
  end

  def show
    @activity = Activity.where(:project_id => current_user.project_ids).find_by_id(params[:id])
    authorize!(:show, @activity) if @activity
    
    if @activity
      api_respond @activity, :references => true, :include => api_include([:uploads])
    else
      api_error :not_found, :type => 'ObjectNotFound', :message => 'Not found'
    end
  end

  protected
  
  def api_scope
    projects = @current_project.try(:id) || current_user.project_ids
    
    conditions = {:project_id => projects}
    conditions[:user_id] = params[:user_id] unless params[:user_id].nil?
    conditions[:target_type] = params[:target_type] unless params[:target_type].nil?
    conditions[:target_id] = params[:target_id] unless params[:target_id].nil?
    conditions[:comment_target_type] = params[:comment_target_type] unless params[:comment_target_type].nil?
    conditions[:comment_target_id] = params[:comment_target_id] unless params[:comment_target_id].nil?
  
    conditions
  end
  
  def get_target
    if params[:project_id] && @current_project.nil?
      api_error :not_found, :type => 'ObjectNotFound', :message => 'Target not found'
    end
  end
  
  def api_include(default=[])
    [:user, :google_docs, :uploads] & ((params[:include]||[])+default).map(&:to_sym)
  end
end
