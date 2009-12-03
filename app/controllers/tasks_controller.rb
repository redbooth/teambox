class TasksController < ApplicationController
  before_filter :find_task_list, :only => [:show,:destroy,:create,:update,:reorder,:archive,:unarchive]
  before_filter :find_task, :only => [:show,:destroy,:update,:archive,:unarchive,:watch,:unwatch]
  
  def not_found
    
  end

  def filter
    if params[:filter_action] == 'asc'
      @comments = tasks.comments.ascending
    elsif params[:filter_action] == 'desc'
      @comments = tasks.comments.descending
    else
      @comments = tasks.comments
    end
      
    respond_to{|f|f.js}
  end

  def sort
    if params[:sort_action] == 'uploads'
      @comments = tasks.comments.with_uploads
    elsif params[:sort_action] == 'hours'
      @comments = tasks.comments.with_hours
    else
      @comments = tasks.comments
    end
        
    respond_to{|f|f.js}
  end
  
  def show
    if @task.archived?    
      @sub_action = 'archived'
      @task_lists = @current_project.task_lists.with_archived_tasks
    else
      @task_lists = @current_project.task_lists
      @sub_action = 'all'
    end  
    @task = @current_project.tasks.find(params[:id])

    @comments = @task.comments
    @comment = @current_project.comments.new
    @comment.target = @task
    @comment.status = @task.status
    
    #   Use this snippet to test the notification emails that we send:
    #@project = @current_project
    #render :file => 'emailer/notify_task', :layout => false
  end
  
  def new
    @task = @task_list.tasks.new
  end
  
  def create
    @task = @current_project.tasks.build(params[:task])
    @task.task_list = @task_list
    @task.user = current_user
    if @task.save    
      @comment = @current_project.comments.new
      @comment.target = @task
      @comment.status = @task.status
    end      
    respond_to do |format|
      format.js
    end
  end
  
  def edit
    respond_to{|f|f.js}
  end
  
  def update
    @task.update_attributes(params[:task])
    respond_to {|f|f.js}
  end
  
  def destroy
    @task.destroy if @task.owner?(current_user)
    respond_to do |format|
      format.html { redirect_to project_task_lists_path(@current_project) }
      format.js
    end
  end
  
  def archive
    @task.update_attribute(:archived,true)
    respond_to {|f|f.js}    
  end
  
  def unarchive
    if @task.update_attribute(:archived,false)
      @task_lists = @current_project.task_lists
      @sub_action = 'all'
      @comment = @current_project.comments.new
      @comment.target = @task
      @comment.status = @task.status
    end
    respond_to {|f|f.js}
  end
  
  def reorder
    @task_list_id = "project_#{@current_project.id}_task_list_#{@task_list.id}_the_tasks"
    params[@task_list_id].each_with_index do |task_id,idx|
      task = @task_list.tasks.find(task_id)
      task.update_attribute(:position,idx.to_i)
    end
  end
  
  def watch
    @task.add_watcher(current_user)
    respond_to{|f|f.js}
  end
  
  def unwatch
    @task.remove_watcher(current_user)
    respond_to{|f|f.js}
  end
  
  private
    
    def find_task_list
      begin
        @task_list = @current_project.task_lists.find(params[:task_list_id])
      rescue
        flash[:error] = "Task list #{params[:task_list_id]} not found in this project"
      end
    end
    
    def find_task
      begin
        @task = @current_project.tasks.find(params[:id])
      rescue
        flash[:error] = "Task #{params[:id]}not found in this project"
      end
    end
end