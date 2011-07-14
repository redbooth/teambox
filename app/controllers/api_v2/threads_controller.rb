class ApiV2::ThreadsController < ApiV2::APIController
  def index
    authorize! :show, @current_project || current_user

    @threads = Activity.includes(:target, :comment_target, :user, :project)
    @threads = @threads.where(:user_id => params[:user_id]) if params[:user_id]
    @threads = @threads.where(:target_type => params[:target_type]) if params[:target_type]
    @threads = @threads.where(:comment_target_type => params[:comment_target_type]) if params[:comment_target_type]
    @threads = @threads.where(:project_id => (@current_project.try(:id) || current_user.project_ids))
    @threads = @threads.limit(api_limit(:hard => true))
    @threads = @threads.where(api_range(:activities))
    @threads = @threads.where(['is_private = ? OR (is_private = ? AND watchers.user_id = ?)', false, true, current_user.id]).
      joins("LEFT JOIN watchers ON ((activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type) OR (activities.comment_target_id = watchers.watchable_id AND watchers.watchable_type = activities.comment_target_type)) AND watchers.user_id = #{current_user.id}")
    @threads = @threads.threads.by_thread
  end

  def show
    @activity = Activity.find(params[:id])
    authorize!(:show, @activity) if @activity
  end
end

