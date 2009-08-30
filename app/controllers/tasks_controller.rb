class TasksController < ApplicationController
  before_filter :load_task_list

  def show
    @task_lists = @current_project.task_lists
    @task = @current_project.tasks.find(params[:id])
    @comments = @task.comments
  end
  
  def new
    @task = @task_list.tasks.new
  end
  
  def create
    @task = @task_list.new_task(current_user,params[:task])
    
    respond_to do |f|
      if @task.save
        f.html { redirect_to project_task_list_path(@current_project,@task_list) }
      else
        f.html { render 'new' }
      end
    end
  end
  
  private
    def load_task_list
      @task_list = TaskList.find(params[:task_list_id])
      
      if @task_list.nil?
        redirect_to project_path(@current_project)
      end
    end
end