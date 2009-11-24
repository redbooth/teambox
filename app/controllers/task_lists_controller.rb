class TaskListsController < ApplicationController
  before_filter :load_task_list, :only => [:update,:show,:destroy,:watch,:unwatch]
    
  def index
    if params.has_key?(:sub_action)
      @sub_action = params[:sub_action]
      if params[:sub_action] == 'mine'
        @task_lists = @current_project.task_lists_assigned_to(current_user)
      elsif params[:sub_action] == 'archived'
        @task_lists = @current_project.task_lists.with_archived_tasks
      end  
    else
      @sub_action = 'all'
      if @current_project
        @task_lists = @current_project.task_lists.unarchived
      else
        @task_lists = []
        current_user.projects.each {|p| @task_lists |= p.task_lists.unarchived }

      end
    end

    @chart_task_lists = []
    @task_lists.each do |task_list|
      #@chart_task_lists << GanttChart::Event.new(task_list.start_on, task_list.finish_on, task_list.name)
    end

    @chart = GanttChart::Base.new(@chart_task_lists)
    
    respond_to do |f|
      f.html
      f.rss { render :layout => false }
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
    @task_lists = @current_project.task_lists.unarchived
    @comments = @task_list.comments
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
  
  def watch
    @task_list.add_watcher(current_user)
    respond_to{|f|f.js}
  end
  
  def unwatch
    @task_list.remove_watcher(current_user)
    respond_to{|f|f.js}
  end
  
  private
    def load_task_list
      @task_list = @current_project.task_lists.find(params[:id])
    end
end