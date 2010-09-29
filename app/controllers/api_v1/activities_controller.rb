class ApiV1::ActivitiesController < ApiV1::APIController
  skip_before_filter :touch_user
  before_filter :get_target

  def index
    projects = @current_project.try(:id) || current_user.project_ids

    @activities = Activity.find_all_by_project_id(projects, :conditions => api_range,
                        :order => 'id DESC',
                        :limit => api_limit,
                        :include => [:target, :project, :user])
    api_respond @activities, :references => (@activities.map(&:target) +  @activities.map(&:project) + @activities.map(&:user)).uniq.compact
  end

  def show
    begin
      @activity = Activity.find params[:id]
    rescue ActiveRecord::RecordNotFound
      return api_status :not_found
    end
    
    if current_user.project_ids.include? @activity.project_id
      api_respond @activity, :include => [:project, :target, :users]
    else
      api_status :unauthorized
    end
  end

  protected
    def get_target
      @target = if params[:project_id]
        @current_project = @current_user.projects.find_by_permalink(params[:project_id])
      else
        @current_user.projects.all
      end
      
      unless @target
        api_status :not_found
      end
    end
end