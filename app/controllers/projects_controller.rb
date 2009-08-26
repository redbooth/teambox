class ProjectsController < ApplicationController
  before_filter :login_required
  before_filter :find_project, :only => [ :show, :edit, :update ]
  layout 'application'
  
  def index
    @projects = current_user.projects
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
  
  private
    def find_project
      @current_project = Project.find_by_permalink(params[:id])
      @project = @current_project
    end
end