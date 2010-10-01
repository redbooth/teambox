class ApiV1::ProjectsController < ApiV1::APIController
  before_filter :load_organization
  before_filter :can_modify?, :only => [:edit, :update, :transfer, :destroy]
  
  def index
    @projects = current_user.projects(:include => [:organization, :user])
    
    api_respond @projects, :references => [:organization, :user]
  end

  def show
    api_respond @current_project, :include => api_include
  end
  
  def create
    @project = current_user.projects.new(params[:project])

    unless current_user.can_create_project?
      api_error(t('projects.new.not_allowed'), :unauthorized)
      return
    end

    if @project.save
      handle_api_success(@project, :is_new => true)
    else
      handle_api_error(@project)
    end
  end
  
  def update
    if @current_project.update_attributes(params[:project])
      handle_api_success(@current_project)
    else
      handle_api_error(@current_project)
    end
  end
  
  def transfer
    unless @current_project.owner?(current_user)
      api_error(t('common.not_allowed'), :unauthorized)
      return
    end
    
    # Grab new owner
    user_id = params[:project][:user_id] rescue nil
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
    @current_project.destroy
    handle_api_success(@current_project)
  end

  protected
  
  def load_project
    if project_id ||= params[:id]
      @current_project = Project.find_by_permalink(project_id)
      api_status(:not_found) unless @current_project
    end
  end
  
  def can_modify?
    if !( @current_project.owner?(current_user) or 
          ( @current_project.admin?(current_user) and 
            !['transfer', 'destroy'].include?(params[:action])))
      
      api_error(t('common.not_allowed'), :unauthorized)
      false
    else
      true
    end
  end
  
  def api_include
    [:organization, :people, :user] & (params[:include]||{}).map(&:to_sym)
  end
  
end