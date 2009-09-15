class HoursController < ApplicationController

  def index
    @current_date = Time.current
    @year = @current_date.year
    @month = @current_date.month
  end
end  