require 'csv'

class HoursController < ApplicationController
  before_filter :check_project
  before_filter :set_page_title
  
  def index
    @go_to_default_path = !(params.has_key?(:year) && params.has_key?(:month))
    @current_date = Time.current

    date_set = if @go_to_default_path
      set_year_month(@current_date.year,@current_date.month)
    else
      set_year_month(params[:year].to_i,params[:month].to_i)
    end
    
    unless date_set
      flash[:error] = "Invalid date"
      if @current_project
        redirect_to project_hours_path(@current_project)
      else
        redirect_to hours_path
      end
      return
    end
    
    conditions = if @current_project
      ['project_id = ? AND created_at >= ? AND created_at < ? AND hours > 0', 
        @current_project.id, @start_date, @end_date]
    else
      ['project_id IN (?) AND created_at >= ? AND created_at < ? AND hours > 0',
        current_user.project_ids, @start_date, @end_date]
    end
    @comments = Comment.find(:all, :conditions => conditions, :include => [:project, :user, :target])
    
    respond_to do |format|
      format.html { }
      format.csv { send_data serialize_comments(@comments), :type => 'text/csv',
                          :filename => "hours-#{@year}-#{@month}.csv" }
    end
  end
  
  def by_period
    @start_date = hours_time('start')
    @end_date = hours_time('end')
    
    if request.format == :csv and @start_date.nil?
      render :text => 'Error, start date not specified!'
      return
    end
    
    @start_date = (@start_date||current_user.created_at).to_date
    @end_date = (@end_date||Time.now).to_date+1
    
    conditions = if @current_project
      ['project_id = ? AND created_at >= ? AND created_at < ? AND hours > 0', 
        @current_project.id, @start_date.to_s(:db_time), @end_date.to_s(:db_time)]
    else
      ['project_id IN (?) AND created_at >= ? AND created_at < ? AND hours > 0',
        current_user.project_ids, @start_date.to_s(:db_time), @end_date.to_s(:db_time)]
    end
    @comments = Comment.find(:all, :conditions => conditions, :include => [:project, :user, :target])
    
    respond_to do |format|
      format.html {}
      format.csv { send_data serialize_comments(@comments), :type => 'text/csv',
                          :filename => "hours-#{@start_date}-#{@end_date}.csv" }
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
  
  def handle_redirect    
    if @go_to_default_path and @current_project
      redirect_to project_hours_by_month_url(@current_project,@year,@month)
    elsif @go_to_default_path and @current_project.nil?
      redirect_to hours_by_month_url(@year,@month)
    else
      false
    end
    true
  end
  
  def serialize_comments(comments)
    csv_io = StringIO.new('', 'w')
    CSV::Writer.generate(csv_io) do |csv|
      csv << ["Time", "Project", "Task", "User", "Person", "Hours", "Description"]
      comments.each do |comment|
        csv << [comment.created_at.to_s(:csv_time),
               comment.project.permalink,
               comment.target.try(:name)||'',
               comment.user.login,
               comment.user.name,
               comment.hours,
               comment.body]
      end
    end
    csv_io.string
  end
  
  def hours_time(prefix)
    begin
      return Date.civil(params[prefix+'_year'].to_i, 
                        params[prefix+'_month'].to_i, 
                        params[prefix+'_day'].to_i)
    rescue
      return nil
    end
  end
  
  def set_year_month(year,month)
    @year = year
    @month = month
    
    begin
      @start_date = Date.civil(@year, @month, 1)
    rescue
      return false
    end
  
    @end_date = @start_date + 1.month
    true
  end
end  