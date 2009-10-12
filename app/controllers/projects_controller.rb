class ProjectsController < ApplicationController
  before_filter :find_project, :only => [ :show, :edit, :update, :accept, :decline ]
  layout 'application'
  
  def index
    @projects = current_user.projects
    @pending_projects = current_user.project_invitations
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
    @activities = @current_project.activities
    
    options = { :include => [:target], :except => ['body_html', :project_id] }
    
    unless @current_project.comments.first.nil?
      CommentRead.user(current_user).read_up_to(@current_project.comments.first,true)
    end
    
    respond_to do |f|
      f.html
      f.xml  { render :xml  => @activities.to_xml(options) }
      f.json { render :json => @activities.to_json(options) }
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @project.update_attributes(params[:project])
        f.html { redirect_to project_path(@project) }
      else
        f.html { render :action => 'edit' }
      end
    end
  end 
  
  def get_comments
    @target = Comment.get_target(params[:target_name],params[:target_id])
    @comments = Comment.get_comments(current_user,@target,params[:show])
  end
  
  def accept
    person = current_user.people.find(:first,:conditions => {
      :project_id => @project.id, :pending => true})
      
    if person
      person.pending = false
      person.save(false)
      redirect_to project_path(@project)
    else
      redirect_to projects_path
    end
  end
  
  def decline
    person = current_user.people.find(:first,:conditions => {
      :project_id => @project.id, :pending => true})

    person.destroy if person
    
    redirect_to projects_path
  end
  
  private
    def find_project
      @current_project = Project.find_by_permalink(params[:id])
      @project = @current_project
      unless @current_project.nil?
        current_user.add_recent_project(@current_project)
      end
    end
end