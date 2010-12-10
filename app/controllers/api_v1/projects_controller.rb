class ApiV1::ProjectsController < ApiV1::APIController
  before_filter :load_organization
  
  def index
    @projects = current_user.projects(:include => [:organization, :user],
                                      :order => 'id DESC')
    
    api_respond @projects, :references => [:organization, :user]
  end

  def show
    api_respond @current_project, :include => api_include
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
  
  def transfer
    authorize! :transfer, @current_project
    
    # Grab new owner
    user_id = params[:user_id] rescue nil
    person = @current_project.people.find_by_user_id(user_id)
    saved = false
    
    # Transfer!
    saved = @current_project.transfer_to(person) unless person.nil?
    
    if saved
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
    if project_id ||= params[:id]
      @current_project = if project_id.match(API_NONNUMERIC)
        Project.find_by_permalink(project_id)
      else
        Project.find_by_id(project_id)
      end
      api_status(:not_found) unless @current_project
    end
  end
  
  def api_include
    [:organization, :people, :user] & (params[:include]||{}).map(&:to_sym)
  end
  
end