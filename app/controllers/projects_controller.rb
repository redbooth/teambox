class ProjectsController < ApplicationController

  layout 'application'
  
  ACTIVITIES_TO_DISPLAY = 30
  
  def index
    @projects = current_user.projects
    @pending_projects = current_user.invitations
    @activities = @projects.collect{ |p| p.activities.all(:limit => ACTIVITIES_TO_DISPLAY, :conditions => "created_at > '#{1.week.ago.to_s(:db)}'") }.flatten.
                            sort{ |x,y| y.created_at <=> x.created_at }[0,ACTIVITIES_TO_DISPLAY]
    
    options = { :include => [:target], :except => 'body_html' }
    
    respond_to do |f|
      f.html
      f.rss { render :layout => false }
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
        flash[:notice] = I18n.t('projects.new.created')
        f.html { redirect_to project_path(@project) }
      else
        flash[:error] = I18n.t('projects.new.invalid_project')
        f.html { render :new }
      end
    end
  end
  
  def show
    @pending_projects = current_user.invitations
    @activities = @current_project.activities.all(:limit => ACTIVITIES_TO_DISPLAY).
                                   sort{|x,y| y.created_at <=> x.created_at}[0,ACTIVITIES_TO_DISPLAY]
    
    options = { :include => [:target], :except => ['body_html', :project_id] }
    
    respond_to do |f|
      f.html
      f.rss { render :layout => false }
      f.xml  { render :xml  => @activities.to_xml(options) }
      f.json { render :json => @activities.to_json(options) }
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