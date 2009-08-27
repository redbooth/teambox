class TaskListsController < ApplicationController
  before_filter :load_task_list, :except => [:index, :new, :create ]
  
  def index
    @task_lists = @current_project.task_lists
  end
  
  def new
    @task_list = @current_project.task_lists.new
  end
  
  def create
    @task_list = @current_project.new_task_list(current_user,params[:task_list])
    
    respond_to do |f|
      if @task_list.save
        f.html { redirect_to project_task_lists_path(@current_project) }
      else
        f.html { render :action => 'new' }
      end
    end
  end
  
  def show
    @tasks = @current_task_list.tasks
  end
  
  private
    def load_task_list
      @current_task_list = TaskList.find(params[:id])
      
      if @current_task_list.nil?
        redirect_to project_path(@current_project)
      end
    end
end