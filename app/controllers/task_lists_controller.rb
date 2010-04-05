class TaskListsController < ApplicationController
  before_filter :load_task_list, :only => [:update,:show,:destroy,:watch,:unwatch]
  before_filter :load_task_lists, :only => [:index, :show]
  before_filter :load_banner, :only => [:index, :show]
  before_filter :check_permissions, :only => [:new,:create,:edit,:update,:destroy]
  before_filter :set_page_title

  cache_sweeper :task_list_panel_sweeper, :only => [:update]

  def index
    respond_to do |f|
      f.html
      f.m
      f.rss   { render :layout => false }
      f.print { render :layout => 'print' }
      f.xml   { render :xml     => @task_lists.to_xml(:include => :tasks, :root => 'task-lists') }
      f.json  { render :as_json => @task_lists.to_xml(:include => :tasks, :root => 'task-lists') }
      f.yaml  { render :as_yaml => @task_lists.to_xml(:include => :tasks, :root => 'task-lists') }
    end
  end

  def show
    @sub_action = 'all'
    @task_lists = @current_project.task_lists.unarchived
    @comments = @task_list.comments

    respond_to do |f|
      f.html
      f.m
      f.xml   { render :xml     => @task_list.to_xml(:include => [:tasks, :comments]) }
      f.json  { render :as_json => @task_list.to_xml(:include => [:tasks, :comments]) }
      f.yaml  { render :as_yaml => @task_list.to_xml(:include => [:tasks, :comments]) }
    end
    #   Use this snippet to test the notification emails that we send:
    # @project = @current_project
    # render :file => 'emailer/notify_task_list', :layout => false
  end

  def new
    @task_list = @current_project.task_lists.new
    respond_to do |f|
      f.m
      f.js
    end
  end

  def create
    if @task_list = @current_project.create_task_list(current_user,params[:task_list])
      @sub_action = 'all'
    end
    respond_to do |f|
      f.html { redirect_to [@current_project,@task_list] }
      f.m    { redirect_to project_task_lists_path(@current_project) }
      f.js
    end
  end

  def update
    @task_list.update_attributes(params[:task_list])
    respond_to {|f|f.js}
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
    if @task_list.editable?(current_user)
      @task_list.try(:destroy)

      respond_to do |f|
        f.html do
          flash[:success] = t('deleted.task_list', :name => @task_list.to_s)
          redirect_to project_task_lists_path(@current_project)
        end
      end
    else
      respond_to do |f|
        flash[:error] = t('common.not_allowed')
        f.html { redirect_to project_task_lists_path(@current_project) }
      end
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
    def load_task_lists
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
          @projects = current_user.projects.unarchived
          conditions = ["project_id IN (?)", Array(@projects).collect{ |p| p.id } ]
          @tasks = Task.find(:all, :conditions => conditions, :include => [:task_list, :user]).
                    select { |task| task.active? }.
                    sort { |a,b| (a.due_on || 1.year.from_now.to_date) <=> (b.due_on || 1.year.from_now.to_date) }
          @task_lists = []
        end
      end
    end

    def load_task_list
      @task_list = @current_project.task_lists.find(params[:id])
    end

end