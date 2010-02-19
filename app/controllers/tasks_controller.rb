class TasksController < ApplicationController
  before_filter :find_task_list, :only => [:show,:destroy,:create,:update,:reorder,:archive,:unarchive,:reopen, :show_in_main_content]
  before_filter :find_task, :only => [:show,:destroy,:update,:archive,:unarchive,:watch,:unwatch,:reopen,:show_in_main_content]
  before_filter :set_page_title
  
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
    @comment = @current_project.new_task_comment(@task)
    #   Use this snippet to test the notification emails that we send:
    #@project = @current_project
    #render :file => 'emailer/notify_task', :layout => false
  end

  def new
    @task = @task_list.tasks.new
  end

  def create
    if @task = @current_project.create_task(current_user,@task_list,params[:task])
      @comment = @current_project.new_task_comment(@task)
    end
    respond_to do |format|
      format.js do
        if @task.valid?
          render :partial => 'tasks/task',
          :locals => {
            :task => @task,
            :project => @current_project,
            :task_list => @task_list,
            :current_target => nil }
        else
          render :text => @task.errors.full_messages.join(" "), :status => 403
        end
      end
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
    if @task.editable?(current_user)
      @task.try(:destroy)

      respond_to do |f|
        f.html do
          flash[:success] = t('deleted.task', :name => @task.to_s)
          redirect_to project_task_lists_path(@current_project)
        end
        f.js
      end
    else
      respond_to do |f|
        flash[:error] = "You are not allowed to do that!"
        f.html { redirect_to project_task_lists_path(@current_project) }
      end
    end
  end

  def archive
    @task.update_attribute(:archived,true)
    respond_to {|f|f.js}
  end

  def reopen
    @task.reopen
    @task.assigned = @current_project.people.find_by_user_id(current_user.id)
    @task.save
    @comment = @current_project.new_task_comment(@task)
    respond_to {|f|f.js}
  end

  def unarchive
    if @task.update_attribute(:archived,false)
      @task_lists = @current_project.task_lists
      @sub_action = 'all'
      @comment = @current_project.new_task_comment(@task)
    end
    respond_to {|f|f.js}
  end

  def reorder
    @task_list_id = "project_#{@current_project.id}_task_list_#{@task_list.id}_the_tasks"
    new_task_ids_for_task_list = params[@task_list_id].reject { |task_id| task_id.blank? }.map(&:to_i)
    moved_task_ids = new_task_ids_for_task_list.to_set - @task_list.task_ids.to_set
    moved_task_ids.each do |moved_task_id|
      Task.find(moved_task_id).update_attribute(:task_list, @task_list)
    end
    new_task_ids_for_task_list.each_with_index do |task_id,idx|
      task = @task_list.tasks.find(task_id)
      task.update_attribute(:position,idx.to_i)
    end
  end

  def show_in_main_content
    @comment = @current_project.new_task_comment(@task)
    render :partial => 'tasks/show',
      :locals => {
        :project => @current_project,
        :task_list => @task_list,
        :task => @task,
        :comment => @comment }
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
        redirect_to project_task_lists_path(@current_project)
      end
    end

    def find_task
      begin
        @task = @current_project.tasks.find(params[:id])
      rescue
        flash[:error] = "Task #{params[:id]} not found in this project"
        redirect_to project_task_lists_path(@current_project)
      end
    end
end