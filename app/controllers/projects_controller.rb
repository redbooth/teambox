class ProjectsController < ApplicationController
  before_filter :find_project, :only => [ :show, :edit, :update ]
  layout 'application'
  
  def index
    @projects = current_user.projects
    @activities = @projects.collect { |p| p.activities }.flatten.sort { |x,y| y.created_at <=> x.created_at }
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
  
  private
    def find_project
      @current_project = Project.find_by_permalink(params[:id])
      @project = @current_project
      unless @current_project.nil?
        current_user.add_recent_project(@current_project)
      end
    end
end