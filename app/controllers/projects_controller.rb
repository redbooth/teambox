class ProjectsController < ApplicationController

  layout 'application'
  
  def index
    @projects = current_user.projects
    @pending_projects = current_user.invitations
    @activities = @projects.collect { |p| p.activities }.flatten.sort { |x,y| y.created_at <=> x.created_at }
    
    options = { :include => [:target], :except => 'body_html' }
    
    respond_to do |f|
      f.html
      f.xml  { render :xml  => @activities.to_xml(options) }
      f.json { render :json => @activities.to_json(options) }
    end
  end

  def new
    @project = Project.new
  end
  
  def create
    @project = current_user.projects.new(params[:project])
    
    respond_to do |f|
      if @project.save
        flash[:notice] = 'Your project has been created.'
        f.html { redirect_to project_path(@project) }
      else
        f.html { render :action => 'new' }
      end
    end
  end
  
  def show
    @pending_projects = current_user.invitations
    @activities = @current_project.activities
    
    options = { :include => [:target], :except => ['body_html', :project_id] }
    
    respond_to do |f|
      f.html
      f.xml  { render :xml  => @activities.to_xml(options) }
      f.json { render :json => @activities.to_json(options) }
    end
  ensure
    unless @current_project.comments.first.nil?
      CommentRead.user(current_user).read_up_to(@current_project.comments.first,true)
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @current_project.update_attributes(params[:project])
        f.html { redirect_to project_path(@current_project) }
      else
        f.html { render :action => 'edit' }
      end
    end
  end 
end