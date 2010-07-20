class ApiV1::ActivitiesController < ApiV1::APIController
  skip_before_filter :load_project, :rss_token, :belongs_to_project?, :recent_projects, :touch_user
  before_filter :get_target

  def index
    @activities = Project.get_activities_for @target
    
    respond_to do |format|
      format.json { render :as_json => @activities.to_xml }
    end
  end

  def show
    begin
      @activity = Activity.find params[:id]
    rescue ActiveRecord::RecordNotFound
      return api_status(:not_found)
    end
    
    if current_user.project_ids.include? @activity.project_id
      respond_to do |f|
        f.json { render :as_json => @activity.to_xml }
      end
    else
      api_status(:unauthorized)
    end
  end

  protected
    def get_target
      @target = if params[:project_id]
        @current_project = @current_user.projects.find_by_permalink(params[:project_id])
      else
        @current_user.projects.find :all
      end
      
      unless @target
        api_status(:not_found)
        return false
      end
    end
  
end