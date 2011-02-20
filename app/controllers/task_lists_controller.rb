class TaskListsController < ApplicationController
  around_filter :set_time_zone, :only => [:index, :show, :gantt_view]
  before_filter :load_task_list, :only => [:edit,:update,:show,:destroy,:watch,:unwatch,:archive,:unarchive]
  before_filter :load_task_lists, :only => [:index, :reorder]
  before_filter :set_page_title
  
  rescue_from CanCan::AccessDenied do |exception|
    # Can they even edit the project?
    if @task_list
      respond_to do |f|
        f.any(:html, :m) { flash[:error] = t('common.not_allowed'); redirect_to_task_list @task_list }
        f.js   {
          render :text => "alert(\"#{t('common.not_allowed')}\");", :status => :unprocessable_entity
        }
        handle_api_error(f, @task_list)
      end
    else
      handle_cancan_error(exception)
    end
  end

  def index
    @on_index = true
    respond_to do |f|
      f.any(:html, :m)
      f.rss {
        @activities = @current_project.activities.for_task_lists.latest
        render :layout => false
      }
      f.js {
        @show_part = params[:part]
        render 'task_lists/reload', :layout => false
      }
      f.print { render :layout => 'print' }
      f.xml   { render :xml     => @task_lists.to_xml(:include => :tasks, :root => 'task-lists') }
      f.json  { render :as_json => @task_lists.to_xml(:include => :tasks, :root => 'task-lists') }
      f.yaml  { render :as_yaml => @task_lists.to_xml(:include => :tasks, :root => 'task-lists') }
    end
  end

  def show
    @comments = @task_list.comments

    respond_to do |f|
      f.any(:html, :m)
      f.js    { calc_onindex; @show_part = params[:part]; render 'task_lists/reload', :layout => false }
      f.xml   { render :xml     => @task_list.to_xml(:include => [:tasks, :comments]) }
      f.json  { render :as_json => @task_list.to_xml(:include => [:tasks, :comments]) }
      f.yaml  { render :as_yaml => @task_list.to_xml(:include => [:tasks, :comments]) }
    end
    #   Use this snippet to test the notification emails that we send:
    # @project = @current_project
    # render :file => 'emailer/notify_task_list', :layout => false
  end

  def new
    authorize! :make_task_lists, @current_project
    @on_index = true
    @task_list = @current_project.task_lists.new
    respond_to do |f|
      f.any(:html, :m)
      f.js { render :layout => false }
    end
  end

  def create
    authorize! :make_task_lists, @current_project
    @on_index = true
    @task_list = @current_project.create_task_list(current_user,params[:task_list])
    
    if !@task_list.new_record?
      respond_to do |f|
        f.html { redirect_to_task_list @task_list }
        f.m    { redirect_to_task_list }
        f.js   { render :layout => false }
        handle_api_success(f, @task_list, true)
      end
    else
      respond_to do |f|
        f.html { render :new }
        f.m    { render :new }
        f.js   { render :layout => false }
        handle_api_error(f, @task_list)
      end
    end
  end
  
  def edit
    authorize! :update, @task_list
    @edit_part = params[:part]
    calc_onindex
    
    respond_to do |f|
      f.any(:html, :m)
      f.js { render :layout => false }
    end
  end

  def update
    authorize! :update, @task_list
    calc_onindex
    @saved = @task_list.update_attributes(params[:task_list])
    
    if @saved
      respond_to do |f|
        f.any(:html, :m) { non_js_list_redirect }
        f.js   { render :layout => false }
        handle_api_success(f, @task_list)
      end
    else
      respond_to do |f|
        f.any(:html, :m) { render :edit }
        f.js   { render :layout => false }
        handle_api_error(f, @task_list)
      end
    end
  end

  def reorder
    authorize! :reorder_objects, @current_project
    task_list_ids = params[:task_list_ids].split(',').collect {|t| t.to_i}
    @task_lists.each do |t|
      next unless task_list_ids.include?(t.id)
      t.position = task_list_ids.index(t.id)
      t.save
    end
    head :ok
  end
  
  def archive
    authorize! :update, @task_list
    calc_onindex
    
    if !@task_list.archived
      # Prototype for comment
      comment_attrs = {}
      comment_attrs[:status] = Task::STATUSES[:resolved]
      comment_attrs[:assigned] = nil
      
      # Resolve all unresolved tasks
      @task_list.tasks.each do |task|
        unless task.archived?
          task.assigned = nil
          task.status = 3
          comment = @current_project.new_comment(current_user,task,comment_attrs)
          comment.save!
        end
      end
      
      @task_list.reload
      @task_list.archived = true
      @task_list.save!
      
      respond_to do |f|
        f.any(:html, :m) { non_js_list_redirect }
        f.js   { render :layout => false }
        handle_api_success(f, @task_list)
      end
    else
      respond_to do |f|
        f.any(:html, :m) { flash[:error] = "Not allowed!"; non_js_list_redirect }
        f.js   { render :text => 'alert("Not allowed!");'; }
        handle_api_error(f, @task_list)
      end
    end
  end
  
  def unarchive
    authorize! :update, @task_list
    calc_onindex
    
    if @task_list.archived
      @task_list.archived = false
      @saved = @task_list.save
    end
    
    if @saved
      respond_to do |f|
        f.js { render 'task_lists/update', :layout => false }
        handle_api_success(f, @task_list)
      end
    else
      respond_to do |f|
        f.js { render 'task_lists/update', :layout => false }
        handle_api_error(f, @task_list)
      end
    end
  end

  def destroy
    calc_onindex
    authorize! :destroy, @task_list
    
    @task_list.try(:destroy)

    respond_to do |f|
      f.any(:html, :m) {
        flash[:success] = t('deleted.task_list', :name => @task_list.to_s)
        redirect_to_task_list }
      f.js   { render :layout => false }
      handle_api_success(f, @task_list)
    end
  end

  def watch
    authorize! :watch, @task_list
    @task_list.add_watcher(current_user)
    respond_to{|f|f.js}
  end

  def unwatch
    @task_list.remove_watcher(current_user)
    respond_to{|f|f.js}
  end

  def gantt_view
    load_gantt_events
  end

  private
    def load_gantt_events
      @chart_task_lists = []
      if @current_project
        @task_lists = (@task_lists || @current_project.task_lists.unarchived)
        conditions = ["project_id = :project_id AND status IN (:status) AND due_on IS NOT NULL", {
                       :project_id => @current_project.id,
                       :status => Task::ACTIVE_STATUS_CODES }]
      else
        @task_lists = current_user.projects.collect { |p| p.task_lists.unarchived }.flatten.compact
        conditions = ["project_id IN (:project_ids) AND status IN (:status) AND due_on IS NOT NULL", {
                       :project_ids => Array(current_user.projects.unarchived).map(&:id),
                       :status => Task::ACTIVE_STATUS_CODES }]
      end
      @tasks = Task.find(:all, :conditions => conditions, :include => [:task_list, :user, :project])
      @events = split_events_by_date(@tasks)

      @task_lists.each do |task_list|
        unless task_list.start_on == task_list.finish_on
          @chart_task_lists << GanttChart::Event.new(
            task_list.start_on,
            task_list.finish_on,
            task_list.name,
            project_task_list_path(task_list.project, task_list))
        end
      end
      @chart = GanttChart::Base.new(@chart_task_lists)
    end

    def load_task_lists
      if @current_project
        @task_lists = @current_project.task_lists(:include => [:project])
      else
        @projects = current_user.projects.unarchived
        
        if [:xml, :json, :as_yaml].include? request.format.to_sym
          @task_lists = TaskList.find(:all,
                                      :include => [:project],
                                      :conditions => {:project_id => @projects.map(&:id)})
          @tasks = []
        else
          @task_lists = []
          conditions = { :project_id => Array(@projects).map(&:id),
                         :status => Task::ACTIVE_STATUS_CODES }
          @tasks = Task.find(:all, :conditions => conditions, :include => [:task_list, :user, :project]).
                    sort { |a,b| (a.due_on || 1.year.from_now.to_date) <=> (b.due_on || 1.year.from_now.to_date) }
        end
      end
      
      @task_lists_archived = @task_lists.reject {|t| !t.archived?}
      @task_lists_active = @task_lists.reject {|t| t.archived?}
      @task_lists = @task_lists_active + @task_lists_archived
    end
    
    def non_js_list_redirect
      if @on_index
        redirect_to project_task_lists_path(@current_project)
      else
        redirect_to project_task_list_path(@current_project,@task_list)
      end
    end

    def load_task_list
      @task_list = @current_project.task_lists.find(params[:id])
    end
    
    def calc_onindex
      @on_index = ((params[:on_index] || 0).to_i == 1)
    end
    
    def redirect_to_task_list(task_list=nil)
      redirect_to task_list ? project_task_list_path(@current_project, @task_list) :
                               project_task_lists_path(@current_project)
    end
end
