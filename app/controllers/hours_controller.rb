class HoursController < ApplicationController
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
end  