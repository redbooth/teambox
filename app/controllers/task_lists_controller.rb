class TaskListsController < ApplicationController
  before_filter :load_task_list, :except => [:index, :new, :create ]

  
  
  def index
    if @current_project.nil?
      @task_lists = []
      @activities = []
      current_user.projects.each do |project|
        @task_lists |= project.task_lists
        @activities |= project.activities.for_task_lists
      end
    else
      @task_lists = @current_project.task_lists
      @activities = @current_project.activities.for_task_lists
    end
  end

  def new
    @task_list = @current_project.task_lists.new
  end
  
  def create
    @task_list = @current_project.new_task_list(current_user,params[:task_list])
    @task_list.save    
    respond_to {|f|f.js}
    
  end
  
  def show
    @task_lists = @current_project.task_lists
    @comments = @task_list.comments
  ensure
    CommentRead.user(current_user).read_up_to(@comments.first) unless @comments.first.nil?
  end
  
  def order
    @task_list_id = "project_#{@current_project.id}_task_list_#{@task_list.id}"
    params[@task_list_id].each_with_index do |task_id,idx|
      task = @task_list.tasks.find(task_id)
      task.update_attribute(:position,idx.to_i)
    end
  end
  
  private
    def load_task_list
      begin
        @task_list = @current_project.task_lists.find(params[:id])
      rescue
        flash[:error] = "Task list #{params[:id]} not found"
      end
      
      if @task_list.nil?
        redirect_to project_path(@current_project)
      end
    end
end