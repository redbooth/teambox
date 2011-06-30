class ApiV2::ActivitiesController < ApiV2::APIController
  def index
    @activities = Activity.includes(:target, :comment_target, :user, :project).limit(5).all
  end
end
