class TasksController < ApplicationController
  before_filter :find_task_list, :only => [:destroy,:create,:update,:check]
  before_filter :find_task, :only => [:destroy,:update,:check,:uncheck]

  def show
    @task_lists = @current_project.task_lists
    @task = @current_project.tasks.find(params[:id])
    @comments = @task.comments
  end
  
  def new
    @task = @task_list.tasks.new
  end
  
  def create
    @task = @current_project.tasks.build(params[:task])
    @task.task_list = @task_list
    @task.user = current_user
    @task.save
    respond_to {|f|f.js}
  end
  
  def update
    @task.update_attributes(params[:task])
    respond_to {|f|f.js}
  end
  
  def destroy
    @task.destroy if @task.owner?(current_user)
    respond_to {|f|f.js}
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