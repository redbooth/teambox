class TasksController < ApplicationController
  before_filter :find_task_list, :only => [:destroy,:create,:update,:check]
  before_filter :find_task, :only => [:destroy,:update,:check,:uncheck]

  def filter
    if params[:filter_action] == 'asc'
      @comments = tasks.comments.ascending
    elsif params[:filter_action] == 'desc'
      @comments = tasks.comments.descending
    else
      @comments = tasks.comments
    end
      
    respond_to do |format|
      format.js
    end    
  end

  def sort
    if params[:sort_action] == 'uploads'
      @comments = tasks.comments.with_uploads
    elsif params[:sort_action] == 'hours'
      @comments = tasks.comments.with_hours
    else
      @comments = tasks.comments
    end
        
    respond_to do |format|
      format.js
    end    
  end
  
  def show
    @task_lists = @current_project.task_lists
    @task = @current_project.tasks.find(params[:id])
    @comments = @task.comments
  ensure
    CommentRead.user(current_user).read_up_to(@comments.first)
  end
  
  def new
    @task = @task_list.tasks.new
  end
  
  def create
    @task = @current_project.tasks.build(params[:task])
    @task.task_list = @task_list
    @task.user = current_user
    respond_to do |format|
      if @task.save
        format.html { redirect_to project_task_list_task_url(@current_project,@task_list,@task) } 
      else
        format.js
      end  
    end  
  end
  
  def update
    @task.update_attributes(params[:task])
    respond_to {|f|f.js}
  end
  
  def destroy
    @task.destroy if @task.owner?(current_user)
    redirect_to project_task_lists_path(@current_project)
  end
  
  def check
    
  end
  
  def uncheck
    
  end
  
  private
    
    def find_task_list
      @task_list = @current_project.task_lists.find(params[:task_list_id])
    end
    
    def find_task
      @task = @current_project.tasks.find(params[:id])
    end
end