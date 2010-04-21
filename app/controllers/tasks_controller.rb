class TasksController < ApplicationController
  before_filter :find_task_list, :only => [:new,:show,:destroy,:create,:update,:reorder]
  before_filter :find_task, :only => [:show,:destroy,:update,:watch,:unwatch]
  before_filter :load_banner, :only => [:show]
  before_filter :set_page_title

  cache_sweeper :task_list_panel_sweeper, :only => [:create, :update, :reorder]

  def show
    @comments = @task.comments
    @comment = @current_project.new_task_comment(@task)

    respond_to do |f|
      f.html
      f.m
      f.js   { @show_part = params[:part]; render :template => 'tasks/reload' }
      f.xml  { render :xml     => @task.to_xml }
      f.json { render :as_json => @task.to_xml }
      f.yaml { render :as_yaml => @task.to_xml }
    end
 
    #   Use this snippet to test the notification emails that we send:
    # @project = @current_project
    # @recipient = current_user
    # render :file => 'emailer/notify_task', :layout => false
  end

  def new
    @task = @task_list.tasks.new
    respond_to do |f|
      f.m
    end
  end

  def create
    if @task = @current_project.create_task(current_user,@task_list,params[:task])
      @comment = @current_project.new_task_comment(@task)
    end
    respond_to do |format|
      format.html { redirect_to [@current_project,@task_list,@task] }
      format.m    { redirect_to project_task_lists_path(@current_project) }
      format.js
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
    @on_task = ((params[:on_task] || 0).to_i == 1)
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
        flash[:error] = t('common.not_allowed')
        f.html { redirect_to project_task_lists_path(@current_project) }
      end
    end
  end

  def reorder
    @task_list_id = "project_#{@current_project.id}_task_list_#{@task_list.id}_the_main_tasks"
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
        flash[:error] = t('not_found.task_list', :id => h(params[:task_list_id]))
        redirect_to project_task_lists_path(@current_project)
      end
    end

    def find_task
      begin
        @task = @current_project.tasks.find(params[:id])
      rescue
        flash[:error] = t('not_found.task', :id => h(params[:id]))
        redirect_to project_task_lists_path(@current_project)
      end
    end
end