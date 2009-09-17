class HoursController < ApplicationController

  def index
    @current_date = Time.current
    @year = @current_date.year
    @month = @current_date.month
    
    @comments = @current_project.comments.with_hours.find_by_month(@month,@year)  
  end
end  