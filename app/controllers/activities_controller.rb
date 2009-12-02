class ActivitiesController < ApplicationController

  skip_before_filter :load_project, :rss_token, :set_page_title, :belongs_to_project?, :recent_projects, :touch_user

  def show_more
    if params[:project_id]
      unless @target = @current_user.projects.find(params[:project_id])
        not_found
        return
      end
    else
      @target = current_user.projects.find :all #, :select => 'projects.id, name'
    end

    @activities = Project.get_activities_for @target, APP_CONFIG['activities_per_page'], params[:id]
    @last_activity = @activities.last
    
    respond_to { |f| f.js }
  end

end