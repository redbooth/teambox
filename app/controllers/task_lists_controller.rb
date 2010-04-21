class TaskListsController < ApplicationController
  before_filter :load_task_list, :only => [:edit,:update,:show,:destroy,:watch,:unwatch,:archive,:unarchive]
  before_filter :load_task_lists, :only => [:index, :show]
  before_filter :load_banner, :only => [:index, :show]
  before_filter :check_permissions, :only => [:new,:create,:edit,:update,:destroy,:archive,:unarchive]
  before_filter :set_page_title

  cache_sweeper :task_list_panel_sweeper, :only => [:update,:archive,:unarchive]

  def index
    @on_index = true
    respond_to do |f|
      f.html
      f.m
      f.js    { @show_part = params[:part]; render :template => 'task_lists/reload' }
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
      f.js    { @show_part = params[:part]; render :template => 'task_lists/reload' }
      f.xml   { render :xml     => @task_list.to_xml(:include => [:tasks, :comments]) }
      f.json  { render :as_json => @task_list.to_xml(:include => [:tasks, :comments]) }
      f.yaml  { render :as_yaml => @task_list.to_xml(:include => [:tasks, :comments]) }
    end
    #   Use this snippet to test the notification emails that we send:
    # @project = @current_project
    # render :file => 'emailer/notify_task_list', :layout => false
  end

  def new
    @on_index = true
    @task_list = @current_project.task_lists.new
    respond_to do |f|
      f.m
      f.js
    end
  end

  def create
    @on_index = true
    if @task_list = @current_project.create_task_list(current_user,params[:task_list])
      @sub_action = 'all'
    end
    respond_to do |f|
      f.html { redirect_to [@current_project,@task_list] }
      f.m    { redirect_to project_task_lists_path(@current_project) }
      f.js
    end
  end
  
  def edit
    @edit_part = params[:part]
    calc_onindex
    
    respond_to do |f|
      f.js
    end
  end

  def update
    calc_onindex
    @task_list.update_attributes(params[:task_list])
    respond_to do |f|
      f.js {}
    end
  end

  def sortable
    @task_lists = @current_project.task_lists
    respond_to {|f|f.js}
  end

  def reorder
    params[:task_lists].each_with_index do |task_list_id,idx|
      task_list = @current_project.task_lists.find(task_list_id)
      task_list.update_attribute(:position,idx.to_i)
    end
    
    respond_to do |f|
      f.js{}
    end
  end
  
  def archive
    calc_onindex
    @sub_action = 'all'
    
    if request.method == :put and @task_list.editable?(current_user) and !@task_list.archived
      # Prototype for comment
      comment_attrs = {:comment_body => params[:message]}
      comment_attrs[:body] ||= "Archived task list"
      comment_attrs[:status] = params[:status] || 3
      
      # Resolve all unresolved tasks
      @task_list.tasks.each do |task|
        if !task.archived?
          task.previous_status = task.status
          task.previous_assigned_id = task.assigned_id
          task.status = comment_attrs[:status]
          task.assigned_id = nil
          comment = @current_project.new_comment(current_user,task,comment_attrs)
          comment.save!
        end
      end
      
      @task_list.reload
      @task_list.archived = true
      @task_list.save!
      
      respond_to do |f|
        f.js{}
      end
    else
      respond_to do |f|
        f.js { render :text => 'alert("Not allowed!");'; }
      end
    end
    
    respond_to do |f|
      f.js{}
    end
  end
  
  def unarchive
    calc_onindex
    @sub_action = 'all'
    
    if request.method == :put and @task_list.editable?(current_user) and @task_list.archived
      @task_list.archived = false
      @task_list.save
    end
    
    respond_to do |f|
      f.js{ render :template => 'task_lists/update' }
    end
  end

  def destroy
    calc_onindex
    if @task_list.editable?(current_user)
      @task_list.try(:destroy)

      respond_to do |f|
        f.html do
          flash[:success] = t('deleted.task_list', :name => @task_list.to_s)
          redirect_to project_task_lists_path(@current_project)
        end
        f.js {}
      end
    else
      respond_to do |f|
        flash[:error] = t('common.not_allowed')
        f.html { redirect_to project_task_lists_path(@current_project) }
        f.js { render :text => 'alert("Not allowed!");'; }
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
        
        # Resort @task_lists and put archived at the bottom
        @task_lists_archived = @task_lists.reject {|t| !t.archived?}
        @task_lists_active = @task_lists.reject {|t| t.archived?}
        @task_lists = @task_lists_active + @task_lists_archived
      else
        @sub_action = 'all'
        if @current_project
          @task_lists = @current_project.task_lists
        else
          @projects = current_user.projects.unarchived
          conditions = ["project_id IN (?)", Array(@projects).collect{ |p| p.id } ]
          @tasks = Task.find(:all, :conditions => conditions, :include => [:task_list, :user]).
                    select { |task| task.active? }.
                    sort { |a,b| (a.due_on || 1.year.from_now.to_date) <=> (b.due_on || 1.year.from_now.to_date) }
          @task_lists = []
        end
        
        # Resort @task_lists and put archived at the bottom
        @task_lists_archived = @task_lists.reject {|t| !t.archived?}
        @task_lists_active = @task_lists.reject {|t| t.archived?}
        @task_lists = @task_lists_active + @task_lists_archived
      end
    end

    def load_task_list
      @task_list = @current_project.task_lists.find(params[:id])
    end
    
    def calc_onindex
      @on_index = ((params[:on_index] || 0).to_i == 1)
    end

end