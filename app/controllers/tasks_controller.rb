class TasksController < ApplicationController
  before_filter :find_task_list, :only => [:new,:show,:destroy,:create,:edit,:update,:reopen,:reorder]
  before_filter :find_task, :only => [:show,:destroy,:edit,:update,:reopen,:watch,:unwatch]
  before_filter :check_permissions, :except => [:show, :watch, :unwatch]
  before_filter :set_page_title

  def show
    @comments = @task.comments
    @comment = @current_project.new_task_comment(@task)

    respond_to do |f|
      f.html { redirect_to_task(@task_list, @task) if @wrong_task_list }
      f.m
      f.js   { @show_part = params[:part]; render :template => 'tasks/reload' }
      f.xml  { render :xml     => @task.to_xml }
      f.json { render :as_json => @task.to_xml }
      f.yaml { render :as_yaml => @task.to_xml }
    end
  end

  def new
    @task = @task_list.tasks.new
    respond_to do |f|
      f.html
      f.m
    end
  end

  def create
    task_params = params[:task]
    assigned_id = task_params ? (task_params[:assigned_id] || '0').to_i : 0
    task_params.merge!({:status => 1}) if assigned_id > 0
    
    if @task = @current_project.create_task(current_user,@task_list,task_params)
      unless @task.new_record?
        @comment = @current_project.new_task_comment(@task)
        @task.reload
      end
    end
    
    if !@task.new_record?
      respond_to do |f|
        f.html { redirect_to_task @task_list, @task }
        f.m    { redirect_to_task @task_list, @task }
        f.js
        handle_api_success(f, @task, true)
      end
    else
      respond_to do |f|
        f.html { render :new }
        f.m    { render :new }
        f.js
        handle_api_error(f, @task)
      end
    end
  end

  def edit
    respond_to do |f|
      f.html
      f.m
      f.js
    end
  end

  def update
    @saved = @task.update_attributes(params[:task])
    if @saved
      respond_to do |f|
        f.html { redirect_to_task @task_list, @task }
        f.m    { redirect_to_task @task_list, @task }
        f.js
        handle_api_success(f, @task)
      end
    else
      respond_to do |f|
        f.html { render :edit }
        f.m    { render :edit }
        f.js
        handle_api_error(f, @task)
      end
    end
  end

  def destroy
    @on_task = ((params[:on_task] || 0).to_i == 1)
    @task.try(:destroy)

    respond_to do |f|
      f.html { flash[:success] = t('deleted.task', :name => @task.to_s); redirect_to_task @task_list }
      f.m    { flash[:success] = t('deleted.task', :name => @task.to_s); redirect_to_task @task_list }
      f.js
      handle_api_success(f, @task)
    end
  end

  def reorder
    @task_list_id = "project_#{@current_project.id}_task_list_#{@task_list.id}_the_main_tasks"
    new_task_ids_for_task_list = (params[@task_list_id] || []).reject { |task_id| task_id.blank? }.map(&:to_i)
    moved_task_ids = new_task_ids_for_task_list.to_set - @task_list.task_ids.to_set
    moved_task_ids.each do |moved_task_id|
      Task.find(moved_task_id).update_attribute(:task_list, @task_list)
    end
    new_task_ids_for_task_list.each_with_index do |task_id,idx|
      task = @task_list.tasks.find(task_id)
      task.update_attribute(:position,idx.to_i)
    end
  end
  
  def reopen
    @task.status = 1
    @task.assigned = @current_project.people.find_by_user_id(current_user.id)
    @comment = @current_project.new_task_comment(@task)
    respond_to {|f|f.js}
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
      @task_list = @current_project.task_lists.find(params[:task_list_id]) rescue nil
    end

    def find_task
      begin
        @task = @current_project.tasks.find(params[:id])
        # Make sure we have the right task list
        if @task_list.try(:id) != @task.task_list_id
          @task_list = @task.task_list
          @wrong_task_list = true
        end
      rescue
        flash[:error] = t('not_found.task', :id => params[:id])
        redirect_to_task
      end
    end
    
    def redirect_to_task(task_list=nil, task=nil)
      if task_list
        redirect_to task ? project_task_list_task_path(@current_project, task_list, task) :
                           project_task_list_path(@current_project, task_list)
      else
        redirect_to project_task_lists_path(@current_project)
      end
    end

    def check_permissions
      # Can they even edit the project?
      unless @current_project.editable?(current_user)
        respond_to do |f|
          f.html { flash[:error] = t('common.not_allowed'); redirect_to_task @task_list, @task }
          f.m    { flash[:error] = t('common.not_allowed'); redirect_to_task @task_list, @task }
          f.js   {
            render :text => "alert(\"#{t('common.not_allowed')}\");", :status => :unprocessable_entity
          }
        end
        return false
      end
    end
end