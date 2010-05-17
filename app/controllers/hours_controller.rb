class HoursController < ApplicationController
  before_filter :check_project
  before_filter :set_page_title
  
  def index
    go_to_default_path = !(params.has_key?(:year) && params.has_key?(:month))
    @current_date = Time.current

    if go_to_default_path
      set_year_month(@current_date.year,@current_date.month)
    else
      set_year_month(params[:year].to_i,params[:month].to_i)
    end
        
    respond_to do |format|
      format.html { redirect_to(project_hours_by_month_url(@current_project,@year,@month)) if go_to_default_path}
    end
  end
  
private
  def check_project
    return if params[:project_id].nil?
    unless @current_project.tracks_time and time_tracking_enabled?
      flash[:error] = "Time tracking disabled"
      redirect_to project_path(@current_project)
    end
  end
  
  def set_year_month(year,month)
    @year = year
    @month = month
    
    begin
      start_month = Date.civil(@year, @month, 1)
    rescue
      flash[:error] = "Invalid date"
      if @current_project
        redirect_to project_hours_path(@current_project)
      else
        redirect_to hours_path
      end
    end
  
    end_month = start_month + 1.month
    if @current_project
      @comments = Comment.find(:all, 
                               :conditions => ['project_id = ? AND created_at >= ? AND created_at < ? AND hours > 0', @current_project.id, start_month, end_month]
                              )
    else
      @comments = Comment.find(:all, 
                               :conditions => ['project_id IN (?) AND created_at >= ? AND created_at < ? AND hours > 0', @current_user.project_ids, start_month, end_month]
                              )
    end
  end
end  