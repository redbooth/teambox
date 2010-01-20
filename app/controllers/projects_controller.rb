class ProjectsController < ApplicationController
  before_filter :load_task_lists, :only => [:show]
  before_filter :load_banner, :only => [:show]
  before_filter :load_projects, :only => [:index]

  def index
    @activities = Project.get_activities_for(@projects)
    @last_activity = @activities.last
    @pending_projects = @current_user.invitations.reload # adding reload to avoid a strange bug
    
    @archived_projects = @current_user.projects.archived

    respond_to do |f|
      f.html
      f.m
      f.rss   { render :layout  => false }
      f.xml   { render :xml     => @projects.to_xml }
      f.json  { render :as_json => @projects.to_xml }
      f.yaml  { render :as_yaml => @projects.to_xml }
      f.print { render :layout  => 'print' }
    end
  end

  def show
    @activities = Project.get_activities_for @current_project
    @last_activity = @activities.last
    @pending_projects = @current_user.invitations.reload
    
    #   Use this snippet to test the notification emails that we send:
    #@project = @current_project
    #render :file => 'emailer/notify_comment', :layout => false
    #return

    respond_to do |f|
      f.html
      f.m
      f.rss   { render :layout  => false }
      f.xml   { render :xml     => @current_project.to_xml }
      f.json  { render :as_json => @current_project.to_xml }
      f.yaml  { render :as_yaml => @current_project.to_xml }
      f.print { render :layout  => 'print' }
    end
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = current_user.projects.new(params[:project])
    
    respond_to do |f|
      if @project.save
        flash[:notice] = I18n.t('projects.new.created')
        f.html { redirect_to project_path(@project) }
      else
        flash[:error] = I18n.t('projects.new.invalid_project')
        f.html { render :new }
      end
    end
  end
  
  def edit
    @sub_action = params[:sub_action] || 'settings'
  end
  
  def update
    respond_to do |f|
      if @current_project.update_attributes(params[:project])
        f.html { redirect_to project_path(@current_project) }
      else
        f.html {
          @sub_action = params.has_key?(:sub_action) ? params[:sub_action] : 'settings'
          render :edit
        }
      end
    end
  end

  def destroy
    @current_project.destroy
    respond_to do |f|
      f.html { redirect_to projects_path }
    end
  end

  protected
  
    def load_task_lists
      @task_lists = @current_project.task_lists.unarchived
    end
  
    def load_projects
      if params.has_key?(:sub_action)
        @sub_action = params[:sub_action]
        if @sub_action == 'archived'
          @projects = current_user.projects.archived
        end  
      else
        @sub_action = 'all'
        @projects = current_user.projects.unarchived
      end
    end

end