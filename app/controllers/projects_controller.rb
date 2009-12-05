class ProjectsController < ApplicationController

  OPTIONS = { :include => [:target], :except => 'body_html' }
  
  def index
    @projects = current_user.projects.find :all #, :select => 'projects.id, name'
    @activities = Project.get_activities_for @projects, APP_CONFIG['activities_per_page']
    @last_activity = @activities.last
    @pending_projects = current_user.invitations

    respond_to do |f|
      f.html
      f.rss  { render :layout => false }
      f.xml  { render :xml  => @activities.to_xml(OPTIONS) }
      f.json { render :json => @activities.to_json(OPTIONS) }
    end
  end

  def show
    @activities = Project.get_activities_for @current_project, APP_CONFIG['activities_per_page']
    @last_activity = @activities.last
    @pending_projects = current_user.invitations
    
    respond_to do |f|
      f.html
      f.rss  { render :layout => false }
      f.xml  { render :xml  => @activities.to_xml(OPTIONS) }
      f.json { render :json => @activities.to_json(OPTIONS) }
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
  end
  
  def update
    respond_to do |f|
      if @current_project.update_attributes(params[:project])
        f.html { redirect_to project_path(@current_project) }
      else
        f.html { render :edit }
      end
    end
  end

end