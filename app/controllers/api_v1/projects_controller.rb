class ApiV1::ProjectsController < ApiV1::APIController
  before_filter :load_project, :except => [:index, :new]
  
  def index
    @projects = current_user.projects
    
    respond_to do |f|
      f.json  { render :as_json => @projects.to_xml }
    end
  end

  def show
  end
  
  def new
    @project = current_user.projects.new(params[:project])
    
    unless current_user.can_create_project?
      return api_error(t('projects.new.not_allowed'), :unprocessable_entity)
    end
    
    respond_to do |f|
      if @project.save
        handle_api_success(f, @project, true)
      else
        handle_api_error(f, @project)
      end
    end
  end
  
  def create
  end
  
  def edit
  end
  
  def update
  end

  def destroy
  end

  protected
  
end