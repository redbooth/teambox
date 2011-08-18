class ApiV1::ProjectsController < ApiV1::APIController
  before_filter :load_organization
  
  def index
    authorize! :show, current_user
    
    @projects = current_user.projects.except(:order).
                             where(api_range('projects')).
                             limit(api_limit).
                             order('projects.id DESC')
    
    api_respond @projects, :references => true
  end

  def show
    authorize! :show, @current_project
    api_respond @current_project, :references => true, :include => api_include
  end
  
  def create
    authorize! :create_project, current_user
    @project = current_user.projects.new(params)

    if @project.save
      handle_api_success(@project, :is_new => true)
    else
      handle_api_error(@project)
    end
  end
  
  def update
    authorize! :update, @current_project
    if @current_project.update_attributes(params)
      handle_api_success(@current_project)
    else
      handle_api_error(@current_project)
    end
  end

  def destroy
    authorize! :destroy, @current_project
    @current_project.destroy
    handle_api_success(@current_project)
  end

  protected
  
  def load_project
    project_id ||= params[:id]
    
    if project_id
      @current_project = Project.find_by_id_or_permalink(project_id)
      api_error 404, :type => 'ObjectNotFound', :message => 'Project not found' unless @current_project
    end
  end
  
  def api_include
    [:people] & (params[:include]||{}).map(&:to_sym)
  end
  
end