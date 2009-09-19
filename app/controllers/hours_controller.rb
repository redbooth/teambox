class HoursController < ApplicationController

  def index
    go_to_default_path = true unless params.has_key?(:year) && params.has_key?(:month)
    @current_date = Time.current
    unless go_to_default_path
      @year = params[:year].to_i
      @month = params[:month].to_i
      @comments = @current_project.comments.with_hours.find_by_month(@month,@year)
    else
      @year = @current_date.year
      @month = @current_date.month        
    end
        
    respond_to do |format|
      format.html { redirect_to(project_hours_by_month_url(@current_project,@year,@month)) if go_to_default_path}
    end
  end
end  