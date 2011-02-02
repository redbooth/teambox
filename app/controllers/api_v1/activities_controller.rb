class ApiV1::ActivitiesController < ApiV1::APIController
  skip_before_filter :touch_user
  before_filter :get_target, :only => [:index]

  def index
    @activities = Activity.where(api_scope).all(:conditions => api_range,
                        :order => 'id DESC',
                        :limit => api_limit,
                        :include => [:target, :project, :user, {:comment_target => [:user, {:recent_comments => :user}]}])
    api_respond @activities,
                :references => [:target, :project, :user, :refs_thread_comments, :refs_comment_target]
  end

  def show
    @activity = Activity.find_by_id params[:id], :conditions => {:project_id => current_user.project_ids}
    
    if @activity
      api_respond @activity, :include => [:project, :target, :user, :thread_comments]
    else
      api_error :not_found, :type => 'ObjectNotFound', :message => 'Not found'
    end
  end

  protected
  
  def api_scope
    projects = @current_project.try(:id) || current_user.project_ids
    
    conditions = {:project_id => projects}
    unless params[:user_id].nil?
      conditions[:user_id] = params[:user_id].to_i
    end
    
    conditions
  end
  
  def get_target
    @target = if params[:project_id]
      @current_project
    else
      @current_user.projects.all
    end
    
    unless @target
      api_error :not_found, :type => 'ObjectNotFound', :message => 'Target not found'
    end
  end
end