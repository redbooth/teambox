class ApiV2::APIController < ActionController::Base
  before_filter :set_client, :load_project

  protected

  def set_client
    request.format = :json unless request.format == :js
  end

  def load_project
    if params[:project_id]
      @current_project = Project.find_by_id_or_permalink(params[:project_id])
    end
  end
end

