class ApiV1::ActivitiesController < ApiV1::APIController
  skip_before_filter :touch_user
  before_filter :get_target

  def index
    projects = @current_project.try(:id) || current_user.project_ids

    @activities = Activity.find_all_by_project_id(projects, :conditions => api_range,
                        :order => 'id DESC',
                        :limit => api_limit)

    api_respond(@activities.to_json(:include => [:project, :target]))
  end

  def show
    begin
      @activity = Activity.find params[:id]
    rescue ActiveRecord::RecordNotFound
      return api_status(:not_found)
    end
    
    if current_user.project_ids.include? @activity.project_id
      api_respond(@activity.to_json(:include => [:project, :target]))
    else
      api_status(:unauthorized)
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
        api_status(:not_found)
      end
    end
    
    def fields_for_object
      {:only => [:id,
                 :project_id,
                 :action,
                 :created_at,
                 :updated_at,
                 :target_id,
                 :target_type],
      :include => {:user => {:only => [:id, :username, :first_name, :last_name], :methods => [:avatar_or_gravatar_url]},
                   :project => {:only => [:id, :name, :permalink]}}
      }
    end
  
end