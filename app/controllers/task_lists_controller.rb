class TaskListsController < ApplicationController
  before_filter :load_task_list, :except => [:index, :new, :create, :sortable, :reorder]
    
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
  
  def update
    @task_list.update_attributes(params[:task_list])
    respond_to {|f|f.js}
  end
  
  def show
    @task_lists = @current_project.task_lists
    @comments = @task_list.comments
  ensure
    CommentRead.user(current_user).read_up_to(@comments.first) unless @comments.first.nil?
  end
  
  def sortable
    @task_lists = @current_project.task_lists
    respond_to {|f|f.js}
  end
  
  def reorder
    params[:sortable_task_lists].each_with_index do |task_list_id,idx|
      task_list = @current_project.task_lists.find(task_list_id)
      task_list.update_attribute(:position,idx.to_i)
    end
  end  

  
  def destroy
    @task_list.destroy if @task_list.owner?(current_user)
    respond_to do |format|
      format.html { redirect_to project_task_lists_path(@current_project) }
      format.js
    end
  end
  
  private
    def load_task_list
      @task_list = @current_project.task_lists.find(params[:id])
    end
end