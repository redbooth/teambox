class TasksController < ApplicationController
  before_filter :load_task_list
  
  def new
    @task = @current_task_list.tasks.new
  end
  
  def create
    @task = @current_task_list.new_task(current_user,params[:task])
    
    respond_to do |f|
      if @task.save
        f.html { redirect_to project_task_list_path(@current_project,@current_task_list) }
      else
        f.html { render :action => 'new' }
      end
    end
  end
  
  private
    def load_task_list
      @current_task_list = TaskList.find(params[:task_list_id])
      
      if @current_task_list.nil?
        redirect_to project_path(@current_project)
      end
    end
end