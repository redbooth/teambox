class TaskListsController < ApplicationController
  before_filter :load_task_list, :except => [:index, :new, :create ]
  
  def index
    @task_lists = @current_project.task_lists
    @activities = @current_project.activities.for_task_lists
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
        f.html { render 'new' }
      end
    end
  end
  
  def show
    @task_lists = @current_project.task_lists
    @comments = @task_list.comments
  ensure
    CommentRead.user(current_user).read_up_to(@comments.first)
  end
  
  def reorder
    render :text => params.inspect
  end
  
  private
    def load_task_list
      @task_list = @current_project.task_lists.find(params[:id])
      
      if @task_list.nil?
        redirect_to project_path(@current_project)
      end
    end
end