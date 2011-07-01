class ApiV2::ActivitiesController < ApiV2::APIController
  def index
    authorize! :show, @current_project || current_user

    @activities = Activity.includes(:target, :comment_target, :user, :project)
    @activities = @activities.where(:project_id => @current_project.id) if @current_project
    @activities = @activities.where(:user_id => params[:user_id]) if params[:user_id]
    @activities = @activities.where(:target_type => params[:target_type]) if params[:target_type]
    @activities = @activities.where(:comment_target_type => params[:comment_target_type]) if params[:comment_target_type]
    @activities = @activities.where(:project_id => (@current_proyect.try(:id) || current_user.project_ids))
    @activities = @activities.threads if params[:threads]
    @activities = @activities.limit(api_limit(:hard => true))
    @activities = @activities.where(api_range(:activities))
    @activities = @activities.order('activities.id DESC')
  end

  def show
    @activity = Activity.find(params[:id])
    authorize!(:show, @activity) if @activity
  end
end

